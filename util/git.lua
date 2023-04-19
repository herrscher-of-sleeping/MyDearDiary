local function get_current_branch()
  local fd = io.popen("git symbolic-ref --short HEAD 2>/dev/null", "r")
  return (fd:read("*all"):match("%S+"))
end

local function get_config_value(name)
  local fd = io.popen("git config --get " .. name .. " 2>/dev/null", "r")
  return (fd:read("*all"):match("(.-)\n"))
end

return {
  get_current_branch = get_current_branch,
  get_config_value = get_config_value,
}
