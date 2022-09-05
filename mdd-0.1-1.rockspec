package = "mdd"
version = "0.1-1"
source = {
  url = "..." -- We don't have one yet
}
description = {
  summary = "Time tracking tool that understands git branches",
  detailed = "lol",
  license = "GNU GPLv3",
  homepage = "lol",
}
dependencies = {
  "lua >= 5.1, <= 5.4",
  "luafilesystem >= 1.8.0, < 1.9.0",
  "luaposix >= 35.1, < 36.0",
  "argparse >= 0.7.1, < 0.8.0",
}
build = {
  type = "builtin",
  install = {
    bin = { mdd = "mdd.lua" }
  },
  modules = {
    ["commands.init"] = "commands/init.lua",
    ["commands.report"] = "commands/report.lua",
    ["commands.start"] = "commands/start.lua",
    ["commands.stop"] = "commands/stop.lua",
    ["commands.pause"] = "commands/pause.lua",
    ["commands.resume"] = "commands/resume.lua",
    ["commands.checkpoint"] = "commands/checkpoint.lua",
    ["util.init"] = "util/init.lua",
    ["util.git"] = "util/git.lua",
    ["util.dialog"] = "util/dialog.lua",
    ["util.time"] = "util/time.lua",
    ["constants"] = "constants.lua",
    ["model"] = "model.lua",
  }
}
