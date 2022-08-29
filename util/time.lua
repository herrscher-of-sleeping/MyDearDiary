local date_format_string = "%Y-%m-%d %H:%M:%S"

local function current_time()
  return os.date(date_format_string)
end

local function parse_time_string(ts)
  local d = {}
  d.year, d.month, d.day, d.hour, d.min, d.sec = ts:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
  return os.time(d)
end

return {
  current_time = current_time,
  parse_time_string = parse_time_string,
}
