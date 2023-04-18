local fs = require "util.fs"
local datafile = require "util.datafile"
local constants = require "constants"

local function get_projects()
  local files, err = fs.get_files(datafile.app_data_path)
  if not files then
    return nil, err
  end

  local projects = {}
  for i, filename in pairs(files) do
    local project_name = filename:match("(.-)." .. constants.log_file_extension)
    table.insert(projects, project_name)
  end
  return projects
end

return {
  get_projects = get_projects
}
