local util = require "util"

local function run(model, args)
  return model:edit_log_in_text_editor()
end

local actions = {
  pause = {
    read = function(args_line)
      local time_string = args_line:match("(.- .-)$")
      local time = util.time.parse_time_string(time_string)
      return { time = time }
    end,
    write = function(time)
      return time
    end
  }
}

return {
  run = run,
  actions = actions,
}
