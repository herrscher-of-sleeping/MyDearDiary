local constants = require "constants"
local util = require "util"

local function try_stop_tracking_and_continue(model, task)
  if util.dialog.ask_for_confirmation("Currently task " .. task .. " is active. Stop task and continue? y/n") then
    local ok, err = model:stop(util.time.current_time())
    if not ok then
      return false, err
    end
    return true
  end
  return false, "Exit"
end

local function run(model, args)
  local task_name = args.task_name or util.git.get_current_branch()
  if not task_name then
    return false, "You must provide task name if it wasn't previously selected or you're not in Git repository"
  end
  local last_line = model:get_tracking_info_at_pos(1)
  if last_line then
    if last_line.action == "start" then
      local ok, err = try_stop_tracking_and_continue(model, last_line.task)
      if not ok then
        return ok, err
      end
    end
  end
  local time = util.time.current_time()
  local ok, err = model:start(time, task_name)
  if not ok then
    return false, err
  end
  return true
end

local function configure_parser(parser)
  parser:argument("task_name"):args("?")
end

return {
  configure_parser = configure_parser,
  run = run,
}
