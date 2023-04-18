local constants = require "constants"
local util = require "util"

local function run(args)
  if not args.project_name then
    return nil, "Need project name"
  end
  local ok, err = util.ini.write(
    constants.config_file,
    { project_name = args.project_name }
  )
  if not ok then
    return nil, err
  end
  return true
end

local function configure(parser)
  parser:argument("project_name"):args("?")
end

return {
  needs_model = false,
  configure = configure,
  run = run,
}
