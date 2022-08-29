local constants = require "constants"

local function run(model, args)
  if model and model:get_config_folder() == constants.config_folder then
    return false, "Configuration already exists, "
      .. "if you want to re-create a new one, delete folder "
      .. constants.config_folder .. " first"
  elseif model then
    print("Configuration exits in " .. model:get_config_folder())
    print("Are you sure to create new configuration in subfolder? y/n")
    local resp = io.read("*line")
    if resp ~= "y" then
      print("Exit")
      return false, "Didn't create config in current project root subfolder"
    end
  end
  local config_path = constants.config_folder .. "/" .. constants.config_file
  local log_path = constants.config_folder .. "/" .. constants.log_file
  local test_fd = io.open(config_path, "r")
  if test_fd then
    test_fd:close()
    return false, "Lua tracker file for project already exists"
  end
  os.execute("mkdir " .. constants.config_folder)
  local fd = io.open(config_path, "w")
  if not fd then
    return false, "Couldn't open file " .. config_path
  end
  fd:write("\n")
  fd:close()

  fd = io.open(log_path, "w")
  if not fd then
    return false, "Couldn't open file " .. log_path
  end
  fd:close()

  return true
end

local function configure_parser(parser)
end

return {
  configure_parser = configure_parser,
  run = run,
}
