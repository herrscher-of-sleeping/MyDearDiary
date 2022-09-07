local util = require "util"

local function run(model, args)
  if not model then
    return nil, "Configuration not found in this folder"
  end
  local last_line = model:get_tracking_info_at_pos(1)
  if last_line.action ~= "start" and last_line.action ~= "resume" then
    return false, "No task is currently running"
  end
  model.commands.pause(util.time.current_time())
  return true
end

local function configure(model, parser)
  if not model then
    return
  end
  model:register_action(
    "pause",
    {
      read = function(args_line)
        local time_string = args_line:match("(.- .-)$")
        local time = util.time.parse_time_string(time_string)
        return { time = time }
      end,
      write = function(time)
        return time
      end
    }
  )
end

return {
  configure = configure,
  run = run
}
