local util = require "util"

local function run(model, args)
  local log_file_lines = model:get_log_lines()
  if #log_file_lines == 0 then
    return false, "No task is currently running"
  end

  local last_line = model:get_tracking_info_at_pos(1)
  if last_line.action == "stop" then
    return false, "No task is currently running"
  end

  local time = util.time.current_time() -- os.time()
  local ok, err = model:stop(time, args.work_description or "")
  if not ok then
    return false, err
  end
  return true
end

local function configure_parser(parser)
  parser:argument("work_description"):args("?")
end

return {
  configure_parser = configure_parser,
  run = run,
}
