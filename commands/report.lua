-- TODO: rewrite this
-- * make reports more compact
-- * add filtering by time
-- * add report for all projects
local util = require "util"

local seconds_per_minute = 60
local minutes_per_hour = 60
local seconds_per_hour = seconds_per_minute * minutes_per_hour

local function split_seconds_to_hours_minutes_seconds(total_seconds)
  local hours = math.floor(total_seconds / seconds_per_hour)
  local minutes = math.floor((total_seconds - hours * seconds_per_hour) / seconds_per_minute)
  local seconds = total_seconds - hours * seconds_per_hour - minutes * seconds_per_minute
  return {
    hours = hours,
    minutes = minutes,
    seconds = seconds,
  }
end

local function pretty_print_duration(seconds)
  local split_time = split_seconds_to_hours_minutes_seconds(seconds)
  return ("%.2dh %.2dm %.2ds"):format(split_time.hours, split_time.minutes, split_time.seconds)
end

local function daily_report(items)
  local reports_per_day = {}
  local current_day
  for i = 1, #items do
    local new_day = os.date("%Y-%m-%d", items[i].start)
    if new_day ~= current_day then
      reports_per_day[new_day] = {}
      current_day = new_day
    end
    if not reports_per_day[current_day][items[i].task] then
      reports_per_day[current_day][items[i].task] = {}
      reports_per_day[current_day][items[i].task].descriptions = {}
      reports_per_day[current_day][items[i].task].start = items[i].start
      reports_per_day[current_day][items[i].task].duration = items[i].stop - items[i].start
    else
      reports_per_day[current_day][items[i].task].duration = (
        reports_per_day[current_day][items[i].task].duration
        + items[i].stop
        - items[i].start
      )
    end
    table.insert(
      reports_per_day[current_day][items[i].task].descriptions,
      {
        description = items[i].description,
        start = items[i].start,
        stop = items[i].stop,
        duration = items[i].stop - items[i].start,
      }
    )
  end
  -- reports_per_day[current_day] = current_day_report
  local reports_as_array = {}
  for day, report in pairs(reports_per_day) do
    local day_items = {}
    table.insert(reports_as_array, { day = day, items = day_items })
    for task, task_report in pairs(report) do
      table.insert(day_items, { task = task, task_report = task_report } )
    end
    table.sort(day_items, function(a, b) return a.task < b.task; end)
  end
  table.sort(reports_as_array, function(a, b) return a.day < b.day; end)
  return reports_as_array
end

local function run(model, args)
  if not model then
    return nil, "Configuration not found in this folder"
  end
  local actions, err = model:get_logged_actions()
  if not actions then
    return nil, err
  end
  local start_stop_pairs = {}
  do
    local pair, last_task
    local paused_pairs = {}
    for _, item in pairs(actions) do
      if item.action == "start" then
        last_task = item.task
        pair = { start = item.time, task = item.task }
      elseif item.action == "stop" then
        if pair.start then
          pair.stop = item.time
          pair.description = item.description
          table.insert(start_stop_pairs, pair)
        end
        for _, paused_pair in pairs(paused_pairs) do
          paused_pair.description = item.description
        end
        paused_pairs = {}
        pair = {}
      elseif item.action == "resume" then
        pair = { start = item.time, task = last_task }
      elseif item.action == "pause" then
        pair.stop = item.time
        table.insert(paused_pairs, pair)
        table.insert(start_stop_pairs, pair)
        pair = {}
      end
    end
  end

  local total_time = 0
  local days = daily_report(start_stop_pairs)
  for i = 1, #days do
    local report = { tasks = {} }
    report.header = "= Day " .. days[i].day .. ": "
    local accumulated_duration = 0
    for j = 1, #days[i].items do
      local task_data = days[i].items[j]
      local task_report = { lines = {} }
      table.insert(report.tasks, task_report)
      task_report.header = " * Task " .. task_data.task .. ", " .. pretty_print_duration(task_data.task_report.duration)
      accumulated_duration = accumulated_duration + task_data.task_report.duration
      -- group descriptions in case of the same desc
      local at_least_one_of_tasks_has_description
      local grouped_by_desc_text = {}
      do
        for _, desc in ipairs(task_data.task_report.descriptions) do
          if desc.description then
            at_least_one_of_tasks_has_description = true
          end
          local description_text = desc.description or "unknown"
          if not grouped_by_desc_text[description_text] then
            grouped_by_desc_text[description_text] = desc
          else
            local grouped_desc = grouped_by_desc_text[description_text]
            grouped_desc.duration = grouped_desc.duration + desc.duration
          end
        end
      end
      if at_least_one_of_tasks_has_description then
        for _, desc in pairs(grouped_by_desc_text) do
          table.insert(
            task_report.lines,
            "   * " .. (desc.description or "unknown") .. ": " .. pretty_print_duration(desc.duration)
          )
        end
      end
    end
    total_time = total_time + accumulated_duration
    report.header = report.header .. pretty_print_duration(accumulated_duration)

    do
      print(report.header)
      for _, task_report in ipairs(report.tasks) do
        print(task_report.header)
        for _, line in pairs(task_report.lines) do
          print(line)
        end
      end
    end
  end
  print("Total time: " .. pretty_print_duration(total_time))

  return true
end

return {
  run = run,
}
