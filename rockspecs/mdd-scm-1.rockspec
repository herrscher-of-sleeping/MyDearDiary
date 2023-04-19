package = "mdd"
version = "scm-1"
source = {
  url = "git@github.com:herrscher-of-sleeping/MyDearDiary.git",
}
description = {
  summary = "Time tracking tool that understands git branches",
  license = "GNU GPLv3",
}
dependencies = {
  "lua >= 5.1, <= 5.4",
  "luafilesystem >= 1.8.0, < 1.9.0",
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
    ["commands.log"] = "commands/log.lua",
    ["commands.project"] = "commands/project.lua",
    ["commands.archive"] = "commands/archive.lua",
    ["commands.edit"] = "commands/edit.lua",
    ["commands.list_projects"] = "commands/list_projects.lua",
    ["util.init"] = "util/init.lua",
    ["util.git"] = "util/git.lua",
    ["util.dialog"] = "util/dialog.lua",
    ["util.time"] = "util/time.lua",
    ["util.fs"] = "util/fs.lua",
    ["util.datafile"] = "util/datafile.lua",
    ["util.ini"] = "util/ini.lua",
    ["util.project"] = "util/project.lua",
    ["constants"] = "constants.lua",
    ["model"] = "model.lua",
  }
}
