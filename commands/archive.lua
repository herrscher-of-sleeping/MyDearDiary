local constants = require "constants"

local function run(model)
  local log_path = constants.config_folder .. "/" .. constants.log_file
  local archive_path = constants.config_folder .. "/" .. constants.archive_file

  local archive_fd = io.open(archive_path, "a+")
  if not archive_fd then
    return nil, "Failed to open file " .. archive_path
  end
  local log_fd = io.open(log_path, "w")
  if not log_fd then
    return nil, "Failed to open file " .. log_path
  end

  for _, line in ipairs(model:get_log_lines()) do
    archive_fd:write(line)
    archive_fd:write("\n")
  end
  archive_fd:close()
  log_fd:write("")
  log_fd:close()

  return true
end

return {
  run = run
}
