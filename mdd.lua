local home = os.getenv("HOME")
local model = require "model"
local argparse = require "argparse"


local commands = {
  init = require "commands.init",
  start = require "commands.start",
  stop = require "commands.stop",
  checkpoint = require "commands.checkpoint",
  report = require "commands.report",
  help = require "commands.help",
}

local parser = argparse()
parser:command_target("command")
for command_name, command_module in pairs(commands) do
  command_module.configure_parser(
    parser:command(command_name)
  )
end

local function main(args)
  local parsed_args = parser:parse(args)
  local command_name = parsed_args.command

  local command_impl = commands[command_name].run

  local model = model.make_model()

  local ok, err = command_impl(model, parsed_args)
  if not ok then
    print("Command failed: ", err)
    os.exit(1)
  end

  if model then
    model:write()
  end
end

main(args or {...})
