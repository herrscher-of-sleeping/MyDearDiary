local constants = require "constants"
local stat = require "posix.sys.stat"
local lfs = require "lfs"
local util = require "util"

local model_mt = {}
model_mt.__index = model_mt

function is_dir(folder_name)
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

function model_mt:write()
  local fd = io.open(self._log_file, "a+")
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
  local parts = { action = action }
  if action == "start" then
    local time_string, task = line:match("%S+ (.- .-) (.+)")
    local time = util.time.parse_time_string(time_string)
    parts.start = time
    parts.task = task
  elseif action == "stop" then
    local time_string = (line:match("%S+ (.- .-) ")) or (line:match("%S+ (.- .-)$"))
    local time = util.time.parse_time_string(time_string)
    local desc = line:match("%S+ .- .- (.+)")
    parts.stop = time
    parts.description = desc
  end
  return parts
end

function model_mt:get_logged_items()
  local items = {}
  local pair = {}
  for i, line in ipairs(self._log) do
    local command_parts = parse_line(line)
    if command_parts.action == "start" then
      pair.start = command_parts.start
      pair.task = command_parts.task
    elseif command_parts.action == "stop" then
      pair.stop = command_parts.stop
      pair.duration = pair.stop - pair.start
      pair.description = command_parts.description
      table.insert(items, pair)
      pair = {}
    end
  end
  return items
end

-- index is reverse: 1 is last
function model_mt:get_tracking_info_at_pos(pos)
  local real_pos = #self._log - pos + 1
  local line = self._log[real_pos]
  if not line then
    return nil
  end
  local command_parts = parse_line(line)
  return command_parts
end

function model_mt:get_config_folder()
  return self._config_folder
end

local function make_model()
  local model = {
    _lines_to_write = {}
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
