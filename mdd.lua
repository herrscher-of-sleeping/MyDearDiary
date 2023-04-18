local modellib = require "model"
local argparse = require "argparse"
local inspect = require "inspect"

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
  ["list-projects"] = require "commands.list_projects",
}

local noop = function() end

local parser = argparse()

local function run_with_model(command_impl, parsed_args)
  local model, err = modellib.make_model(parsed_args.force_project)
  if not model then
    return nil, err
  end
  local ok, err = command_impl(model, parsed_args)
  if not ok then
    return nil, err
  end
  return model:save()
end

local function run_without_model(command_impl, parsed_args)
  return command_impl(parsed_args)
end

local function main(args)
  parser:command_target("command")
  parser:option("-p --project", "Optional project path"):target("force_project")
  for command_name, command_module in pairs(commands) do
    local configure = command_module.configure or noop
    configure(parser:command(command_name))

    local cmd_actions = command_module.actions or {}
    for k, v in pairs(cmd_actions) do
      modellib.register_action(k, v)
    end
  end

  local parsed_args = parser:parse(args)
  local command_name = parsed_args.command
  local command_impl = commands[command_name].run
  local needs_model = commands[command_name].needs_model

  local run_cmd = (needs_model == false)
    and run_without_model
    or run_with_model
  local ok, err = run_cmd(command_impl, parsed_args)
  if not ok then
    print("Command failed: " .. (err or "Unknown error"))
    print(parser:get_usage())
    os.exit(1)
  end
end

return main(args or {...})
