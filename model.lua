local constants = require "constants"
local stat = require "posix.sys.stat"
local util = require "util"

local model_mt = {}
model_mt.__index = model_mt

local function is_dir(folder_name)
  local stat_ = stat.stat(folder_name)
  if stat_ then
    local root_stat_ = stat.stat("/")
    if root_stat_.st_ino == stat_.st_ino then
      return false, "Couldn't open directory " .. folder_name
    end
    return stat.S_ISDIR(stat_.st_mode)
  end
  return false, "Couldn't open directory " .. folder_name
end

local function find_config_folder()
  local dir_path = "."
  while is_dir(dir_path) do
    local config_folder
    if dir_path == "." then
      config_folder = constants.config_folder
    else
      config_folder = dir_path .. "/" .. constants.config_folder
    end
    if is_dir(config_folder) then
      return config_folder
    end
    if dir_path == "." then
      dir_path = ".."
    else
      dir_path = dir_path .. "/.."
    end
  end
  return false, "Config not found"
end

local function read_log_file(log_file)
  local strings = {}
  local fd = io.open(log_file, "r+")
  if not fd then
    return false, "Couldn't open file " .. log_file
  end
  for line in fd:lines() do
    table.insert(strings, line)
  end
  fd:close()
  return strings
end

function model_mt:write(format_string, ...)
  local line_to_write = format_string:format(...)
  table.insert(self._lines_to_write, line_to_write)
end

function model_mt:start(time, task)
  if type(task) ~= "string" then
    return false, "Task is of type " .. type(task)
  end
  if type(time) ~= "string" then
    return false, "Time is of type " .. type(time)
  end
  local text = ("start %s %s"):format(time, task)
  table.insert(self._lines_to_write, text)
  return true
end

function model_mt:stop(time, desc)
  if type(time) ~= "string" then
    return false, "Time is of type " .. type(time)
  end
  local text
  if desc then
    text = ("stop %s %s"):format(time, desc)
  else
    text = ("stop %s"):format(time)
  end
  table.insert(self._lines_to_write, text)
  return true
end

local line_parsers = {}

function model_mt:register_action(command, handlers)
  self.commands[command] = function(...)
    local line = command .. " " .. handlers.write(...)
    table.insert(self._lines_to_write, line)
    return true
  end
  line_parsers[command] = handlers.read
end

function model_mt:save()
  local fd = io.open(self._log_file, "a+")
  if not fd then
    return nil, "Couldn't open log file " .. self._log_file
  end
  for _, line in ipairs(self._lines_to_write) do
    fd:write(line)
    fd:write("\n")
  end
  fd:close()
end

function model_mt:get_log_lines()
  return self._log
end

local function parse_line(line)
  local action = line:match("(%S+) ")
  if not action then
    return { action = "dummy" }
  end
  if line_parsers[action] then
    local args_string = line:match("%S+ (.+)")
    local parts, err = line_parsers[action](args_string)
    parts.action = action
    return parts, err
  else
    return nil, "Unknown command " .. action
  end
end

function model_mt:get_logged_actions()
  local items = {}
  for i, line in ipairs(self._log) do
    local command_parts, err = parse_line(line)
    if not command_parts then
      return nil, err
    end
    if command_parts.action ~= "dummy" then
      table.insert(items, command_parts)
    end
  end
  return items
end

-- index is reverse: 1 is last
function model_mt:get_tracking_info_at_pos(pos)
  local lines, err = self:get_logged_actions()
  if not lines then
    return nil, err
  end

  local real_pos = #lines - pos + 1
  local line = lines[real_pos]
  return line
end

function model_mt:get_last_paused_task_start()
  local lines, err = self:get_logged_actions()
  if not lines then
    return nil, err
  end

  if not lines[1] then
    return nil
  end

  local paused_item
  for i = #lines, 1, -1 do
    local item = lines[i]
    if item.action == "pause" then
      paused_item = item
    elseif paused_item and item.action == "start" then
      return item
    end
  end
end

function model_mt:get_last_task_info()
  local lines, err = self:get_logged_actions()
  if not lines then
    return nil, err
  end

  if not lines[1] then
    return nil
  end

  for i = #lines, 1, -1 do
    local item = lines[i]
    if item.action == "start" then
      return {
        status = "running",
        task = item.task,
      }
    elseif item.action == "resume" then
      local task_start = self:get_last_paused_task_start()
      if not task_start then
        return nil, "Error in log: couldn't find start of paused task"
      end
      return {
        status = "running",
        task = task_start.task,
      }
    elseif item.action == "stop" then
      return nil
    elseif item.action == "pause" then
      local task_start = self:get_last_paused_task_start()
      if not task_start then
        return nil, "Error in log: couldn't find start of paused task"
      end
      return {
        status = "paused",
        task = task_start.task,
      }
    end
  end
end

function model_mt:get_config_folder()
  return self._config_folder
end

local function make_model()
  local model = {
    _lines_to_write = {},
    commands = {},
  }
  setmetatable(model, model_mt)
  local config_folder, err = find_config_folder()
  model._config_folder = config_folder
  if not model._config_folder then
    return nil, err
  end
  local log_file = config_folder .. "/" .. constants.log_file
  model._log = read_log_file(log_file)
  model._log_file = log_file
  return model
end

return {
  make_model = make_model
}
