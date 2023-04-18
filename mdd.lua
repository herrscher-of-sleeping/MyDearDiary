local make_model = require("model").make_model
local argparse = require "argparse"

local commands = {
  init = require "commands.init",
  project = require "commands.project",
  start = require "commands.start",
  stop = require "commands.stop",
  checkpoint = require "commands.checkpoint",
  report = require "commands.report",
  pause = require "commands.pause",
  resume = require "commands.resume",
  log = require "commands.log",
  archive = require "commands.archive",
}

local noop = function() end

local parser = argparse()

local function main(args)
  local model, err = make_model(args[1] == "init", args[2])
  if not model then
    print(err)
    os.exit(1)
  end

  parser:option("-p --project", "Project name")

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
    print(parser:get_usage())
    os.exit(1)
  end

  if model then
    model:save()
  end
end

return main(args or {...})
