local util = require "util"

local function run(model, args)
  for _, line in ipairs(model:get_log_lines()) do
    print(line)
  end
  return true
end

return {
  run = run
}
