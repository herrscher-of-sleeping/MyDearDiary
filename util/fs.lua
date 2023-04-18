local lfs = require "lfs"

local function make_check_is(test_mode)
  return function(path)
    local mode, err = lfs.attributes(path, "mode")
    if not mode then
      return nil, err
    end
    return mode == test_mode
  end
end

local is_dir = make_check_is("directory")
local is_file = make_check_is("file")

local function get_files(folder_path)
  local files = {}
  if not is_dir(folder_path) then
    return false, "Not a directory: " .. folder_path
  end
  for file in lfs.dir(folder_path) do
    if is_file(folder_path .. "/" .. file) then
      table.insert(files, file)
    end
  end
  return files
end

return {
  get_files = get_files,
  is_dir = is_dir,
  is_file = is_file,
}
