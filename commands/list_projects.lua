local util = require "util"
local constants = require "constants"

local function run(args)
  local projects, err = util.project.get_projects()
  if not projects then
    return nil, err
  end
  print(table.concat(projects, "\n"))
  return true
end

return {
  needs_model = false,
  run = run,
}
