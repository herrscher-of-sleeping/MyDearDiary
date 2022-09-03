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
	local ok, err = model:stop(time, description)
	if not ok then
		return ok, err
	end
	ok, err = model:start(time, last_line.task)
	if not ok then
		return ok, err
	end
  return true
end

local function configure_parser(parser)
  parser:argument("description")
end

return {
  configure_parser = configure_parser,
  run = run,
}
