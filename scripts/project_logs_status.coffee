# Description:
#   Get Person Project Logs status
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot projectlogs
#
# Author:
#   Tayyab <tayyab.razzaq@arbisoft.com>



formatLogs = (projectLogs, username) ->
  logs = "Hey @" + username
  logs += ",\nPlease complete your project logs for the following week(s):\n"
  for person_week_log in projectLogs
    person_week_projects = person_week_log['person_week_projects']
    projects = ""
    if person_week_projects.length != 0
      projects = " ( "
      first = true
      for projectTeam in person_week_projects
        if first is false
          projects += ' , '
        else
          first = false
        projects += projectTeam['team'] + '-' + projectTeam['subteam']
      projects += " )"
    logs += person_week_log['week_starting'] + " to " + person_week_log['week_ending'] + projects + "\n"
  logs += "To complete the logs, go to https://hrdb.arbisoft.com/app\nThank you!"
  return logs

sendMessageToUser = (robot, username, logs) ->
  (robot.adapter.chatdriver.getDirectMessageRoomId username).then (DM) ->
    robot.adapter.chatdriver.sendMessageByRoomId logs, DM.rid

getProjectLogsStatus = (robot, username, id) ->
  url = "https://hrdb.arbisoft.com/project-logs/incomplete-logs?person_id=#{id}"
  robot.http(url).get() (err, res, body) ->
    if res.statusCode isnt 200
      res.send "Request didn't come back HTTP 200 :("
      return

    data = JSON.parse body
    if data.length != 0
      logs = formatLogs(data, username)
      sendMessageToUser(robot, username, logs)

sendMessageToPersons = (robot , userDetails) ->
  userlist = ["tayyab.razzaq", "ayesha.mahmood"]
  for key,value of userDetails
    if key in userlist
      getProjectLogsStatus(robot, key, value)

getPersons = (robot) ->
  url = "https://hrdb.arbisoft.com/project-logs/incomplete-log-users"
  robot.http(url).get() (err, res, body) ->
    if res.statusCode isnt 200
      res.send "Request didn't come back HTTP 200 :("
      return

    data = JSON.parse body
    if data.length != 0
      userDetails = {}
      for person in data
        console.log person
        userDetails[person["username"]] = person["id"]
      sendMessageToPersons(robot, userDetails)


module.exports = (robot) ->

  cronJob = require('cron').CronJob
  pattern = '00 00 14 * * 1-5'
  new cronJob(pattern, (->
    do everyMinute
  ), null, true)

  everyMinute = ->
    getPersons(robot)