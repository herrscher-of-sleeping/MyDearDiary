local constants = require "constants"
local util = require "util"

local function run(model, args)
  return model:initialize(args.project_name)
end

local function configure(model, parser)
  parser:argument("project_name"):args("?")
end

return {
  configure = configure,
  run = run,
}
