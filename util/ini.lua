local function read_ini(file_path)
  local fd = io.open(file_path, "r+")
  if not fd then
    return nil, "Couldn't open file " .. file_path
  end
  local kv = {}
  for line in fd:lines() do
    local k, v = line:match("^(%S-)=(%S-)$")
    if k and v then -- Let's ignore any bad lines for now
      kv[k] = v
    end
  end
  fd:close()
  return kv
end

local function format_ini(kv)
  local lines = {}
  for k, v in pairs(kv) do
    table.insert(lines, k .. "=" .. v)
  end
  table.sort(lines)
  table.insert(lines, "")
  return table.concat(lines, "\n")
end

local function write_ini(file_path, kv)
  local fd = io.open(file_path, "w+")
  if not fd then
    return nil, "Couldn't open file " .. file_path
  end
  fd:write(format_ini(kv))
  fd:close()
  return true
end

return {
  format_ini = format_ini,
  read = read_ini,
  write = write_ini,
}
