local lfs = require "lfs"
local stat = require "posix.sys.stat"
local fs = require "util.fs"

local xdg_data_path = os.getenv("XDG_DATA_PATH") or
    os.getenv("HOME") .. "/.local/share/"

local function open(name, mode)
  local folder_path = xdg_data_path .. "mdd/"
  if not fs.is_dir(folder_path) then
    lfs.mkdir(folder_path)
  end
  local file_path = folder_path .. name
  local fd, err = io.open(file_path, mode)
  if not fd then
    return nil, err
  end
  return fd
end

return {
  open = open
}
