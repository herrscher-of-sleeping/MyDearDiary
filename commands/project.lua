local constants = require "constants"

local function run(model, args)
  if args.project_name then
    return model:set_config_value("project_name", args.project_name)
  else
    print(model.project_name)
  end
  return true
end

local function configure(parser)
  parser:argument("project_name"):args("?")
end

return {
  configure = configure,
  run = run,
}
