local constants = require "constants"
local lfs = require "lfs"
local fs = require "util.fs"

local xdg_data_path = os.getenv("XDG_DATA_PATH") or
    os.getenv("HOME") .. "/.local/share/"

local app_data_path = xdg_data_path .. "/" .. constants.app_name

local function open(name, mode)
  if not fs.is_dir(app_data_path) then
    lfs.mkdir(app_data_path)
  end
  local file_path = app_data_path .. name
  local fd, err = io.open(file_path, mode)
  if not fd then
    return nil, err
  end
  return fd
end

return {
  app_data_path = app_data_path,
  open = open,
}
