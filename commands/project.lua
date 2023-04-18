local constants = require "constants"

local function run(model, args)
  model:set_config_value("project_name", args.project_name)
  return true
end

local function configure(parser)
  parser:argument("project_name"):args("?")
end

return {
  configure = configure,
  run = run,
}
