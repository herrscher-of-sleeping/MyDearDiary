local function ask_for_confirmation(text)
  print(text)
  local line = io.read("*line")
  if line == "y" or line == "Y" then
    return true
  end
  return false
end

return {
  ask_for_confirmation = ask_for_confirmation
}
