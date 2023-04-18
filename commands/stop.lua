local util = require "util"

local function run(model, args)
  if not model then
    return nil, "Configuration not found in this folder"
  end
  local log_file_lines = model:get_log_lines()
  if #log_file_lines == 0 then
    return false, "No task is currently running"
  end

  local last_line = model:get_tracking_info_at_pos(1)
  if last_line.action == "stop" then
    return false, "No task is currently running"
  end

  local time = util.time.current_time()
  local ok, err = model.actions.stop(time, args.work_description or "")
  if not ok then
    return false, err
  end
  return true
end

local actions = {
  stop = {
    write = function(time, descr)
      if descr then
        return ("%s %s"):format(time, descr)
      else
        return ("%s"):format(time)
      end
    end,
    read = function(line)
      local time_string = (line:match("(.- .-) ")) or (line:match("(.- .-)$"))
      local time = util.time.parse_time_string(time_string)
      local desc = line:match(".- .- (.+)")
      return { time = time, description = desc }
    end
  }
}

local function configure(parser)
  parser:argument("work_description"):args("?")
end

return {
  configure = configure,
  run = run,
  actions = actions,
}
