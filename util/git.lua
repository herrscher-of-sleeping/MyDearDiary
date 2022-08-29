local function get_current_branch()
  local fd = io.popen("git rev-parse --abbrev-ref HEAD 2>/dev/null", "r")
  return (fd:read("*all"):match("%S+"))
end

return {
  get_current_branch = get_current_branch
}
