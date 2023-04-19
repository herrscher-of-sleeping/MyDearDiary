local function get_current_branch()
  local fd = io.popen("git symbolic-ref --short HEAD 2>/dev/null", "r")
  return (fd:read("*all"):match("%S+"))
end

return {
  get_current_branch = get_current_branch
}
