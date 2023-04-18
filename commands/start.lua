local constants = require "constants"
local util = require "util"

local function try_stop_tracking_and_continue(model, task)
  if util.dialog.ask_for_confirmation("Currently task " .. task .. " is active. Stop task and continue? y/n") then
    model.actions.stop(util.time.current_time())
    return true
  end
  return false, "Exit"
end

local function run(model, args)
  if not model then
    return nil, "Configuration not found in this folder"
  end
  local task_name = args.task_name or util.git.get_current_branch()
  if not task_name then
    return false, "You must provide task name if it wasn't previously selected or you're not in Git repository"
  end
  local last_task_info = model:get_last_task_info()
  if last_task_info then
    if last_task_info.status == "running" or last_task_info.status == "paused" then
      local ok, err = try_stop_tracking_and_continue(model, last_task_info.task)
      if not ok then
        return ok, err
      end
    end
  end
  local time = util.time.current_time()
  local ok, err = model.actions.start(time, task_name)
  return ok, err
end

local function configure(parser)
  parser:argument("task_name"):args("?")
end

local actions = {
  start = {
    write = function(time, task)
      return ("%s %s"):format(time, task)
    end,
    read = function(args_line)
      local time_string, task = args_line:match("(.- .-) (.+)")
      local time = util.time.parse_time_string(time_string)
      return { time = time, task = task }
    end,
  }
}

return {
  configure = configure,
  run = run,
  actions = actions,
}
