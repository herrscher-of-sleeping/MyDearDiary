local model = require "model"
local argparse = require "argparse"

local commands = {
  init = require "commands.init",
  start = require "commands.start",
  stop = require "commands.stop",
  checkpoint = require "commands.checkpoint",
  report = require "commands.report",
  pause = require "commands.pause",
  resume = require "commands.resume",
}

local noop = function() end

local parser = argparse()

local function main(args)
  local model = model.make_model()

  parser:command_target("command")
  for command_name, command_module in pairs(commands) do
    local configure = command_module.configure or noop
    configure(model, parser:command(command_name))
  end

  local parsed_args = parser:parse(args)
  local command_name = parsed_args.command

  local command_impl = commands[command_name].run

  local ok, err = command_impl(model, parsed_args)
  if not ok then
    print("Command failed: ", err)
    os.exit(1)
  end

  if model then
    model:save()
  end
end

main(args or {...})
