local constants = require "constants"
local git = require "util.git"
local util = require "util"

local function run(model, args)
  local description = args.description
  if not description then
    return false, "You must provide description"
  end
  local last_line = model:get_tracking_info_at_pos(1)
  if not last_line or last_line.action ~= "start" then
    return false, "Task hasn't been started"
  end
  local time = util.time.current_time()
  local ok, err = model.commands.stop(time, description)
  if ok then
    ok, err = model.commands.start(time, last_line.task)
  end
  return ok, err
end

local function configure(model, parser)
  parser:argument("description")
end

return {
  configure = configure,
  run = run,
}
