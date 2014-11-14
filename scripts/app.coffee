'use strict'

cheerio      = require 'cheerio'
async        = require 'async'
cron         = require('cron').CronJob
dayInfoArray = []
baseInfoObj  = {}

class dayInfo
  constructor:(day) ->
    @dayObj = {}
    @dayObj.date    = day.attr 'data-date'
    @dayObj.dateCnt = day.attr 'data-count' 
    @dayObj.color   = day.attr 'fill'
  getDayData: ->
    return @dayObj

# calc
parseContributions = (robot,mainCallBack) ->
  async.waterfall( [
    (callback) ->
      username = "abouthiroppy"
      url      = "https://github.com/users/#{username}/contributions"

      robot.http(url).get() (err, res, body) ->
        $ = cheerio.load body
        dayInfoArray = []
        $('svg > g > g > rect').each(()->
          day = $(@)
          dayInfoArray.push(new dayInfo(day))
        )

        baseObj  = {}
        baseObj.all                 = 0 # Year of contributions
        baseObj.allPeriod           = "\(#{dayInfoArray[0].getDayData().date} - #{dayInfoArray[dayInfoArray.length-1].getDayData().date}\)"
        baseObj.longestStreak       = 0
        baseObj.longestStreakPeriod = ""
        LongestStreakArray          = []
        baseObj.currentStreak       = 0
        baseObj.currentStreakPeriod = ""
        CurrentStreakFlag           = false

        for i in [dayInfoArray.length-1 .. 0]
          baseObj.all += ~~dayInfoArray[i].getDayData().dateCnt
          if dayInfoArray[i].getDayData().dateCnt isnt '0'
            # current streak
            if CurrentStreakFlag is false
              baseObj.currentStreak++

            # long streak
            baseObj.longestStreak++

          else
            if (i isnt dayInfoArray.length-1) and (CurrentStreakFlag is false)
              CurrentStreakFlag = true
              # finish date(currentStreak)
              if baseObj.currentStreak isnt 0
                baseObj.currentStreakPeriod = "\(#{dayInfoArray[i].getDayData().date} - #{dayInfoArray[dayInfoArray.length-1].getDayData().date}\)"
            LongestStreakArray.push baseObj.longestStreak
            baseObj.longestStreak = 0

        baseObj.longestStreak = Math.max.apply null, LongestStreakArray
        baseInfoObj = baseObj
        callback()
    ],()->
      mainCallBack()
    )


contributionsCalendar = () ->



module.exports = (robot) ->
  date  = new Date
  today = date.getFullYear().toString() + ('0' + (date.getMonth() + 1).toString()).slice(-2) + ('0' + date.getDate().toString()).slice(-2)

  parseContributions(robot, ()->)

  # notification   
  new cron '00 00 3,15,21,23 * * *', () =>
    parseContributions(robot, ()->
      # if dayInfoArray[dayInfoArray.length-1].getDayData().dateCnt is 0
      #   robot.send {room: '#bot-debug'},  "Please grow grass :("
      # test
      if dayInfoArray[0].getDayData().dateCnt is 0
        robot.send {room: '#bot-debug'},  "Please grow grass :("
    )
  , null, true, 'Asia/Tokyo'

  robot.hear /info$/i, (msg) ->
    msg.send ">>> Year of contributions: #{baseInfoObj.all} total #{baseInfoObj.allPeriod}\nLongest streak: #{baseInfoObj.longestStreak} days\nCurrent streak: #{baseInfoObj.currentStreak} days #{baseInfoObj.currentStreakPeriod}"

  robot.hear /reload$/i, (msg) ->
    parseContributions(robot, ()->
      msg.send "Update complete"
    )
