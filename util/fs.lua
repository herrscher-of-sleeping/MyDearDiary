local stat = require "posix.sys.stat"

local function make_check_is(s_is)
  return function(path)
    local stat_ = stat.stat(path)
    if stat_ then
      local root_stat_ = stat.stat("/")
      if root_stat_.st_ino == stat_.st_ino then
        return false, "Couldn't open directory or file " .. path
      end
      return s_is(stat_.st_mode)
    end
    return false, "Couldn't open directory or file " .. path
  end
end

local is_dir = make_check_is(stat.S_ISDIR)
local is_file = make_check_is(stat.S_ISREG)

return {
  is_dir = is_dir,
  is_file = is_file,
}
