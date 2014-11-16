'use strict'

cheerio      = require 'cheerio'
async        = require 'async'
cron         = require('cron').CronJob
dayInfoArray = []
baseInfoObj  = {}
username     = 'abouthiroppy'
url          = "https://github.com/users/#{username}/contributions"


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
    ], () ->
      mainCallBack()
    )

# trend of this week
trendThisWeek = (mainCallBack) ->
  # emoji list
  # less 🔥(:fire:) -> 🌱(:seedling:) -> 🌴(:palm_tree:) -> 🌼(:blossom:) -> 🌺(:hibiscus:) more
  ### e.g
  ---  2014-11-09 - 2014-11-15  ---  
  09 🌱🌱🌱🌱     (+3)
  10 🌱     (-2)
  11 🌱🌱🌱🌱🌱     (-7)
  12 🌱🌱🌱🌱🌱🌴🌴     (-6)
  13 🌱🌱🌱🌱🌱🌴🌴🌴🌴🌴🌼🌼🌼🌼🌼🌺🌺🌺     (+15)
  14 🌱🌱     (-6)
  15 🌱🌱🌱🌱🌱     (-2)
  ### 

  message = ""
  async.waterfall( [
    (callback) ->
      len = dayInfoArray.length
      message += ">>>   #{dayInfoArray[len-7].getDayData().date} - #{dayInfoArray[len-1].getDayData().date}  (difference with last week)\n"
      message += '-----------------------------------------------------------------------------------------\n'
      trendLastWeek = () ->
        diff = ~~dayInfoArray[i].getDayData().dateCnt - ~~dayInfoArray[i-7].getDayData().dateCnt
        if diff > 0
          diff = '+' + diff
        return '(' + diff + ')\n'

      for i in [len-7 ... len]
        message += (dayInfoArray[i].getDayData().date.split('-')[2] + ' ')
        # fire
        if dayInfoArray[i].getDayData().dateCnt is '0'
          message += ':fire:     '
          message += trendLastWeek()
        else
          for j in [1 .. dayInfoArray[i].getDayData().dateCnt]
            if j <= 5
              message += ':seedling:'
            else if j <= 10
              message += ':palm_tree:'
            else if j <= 15
              message += ':blossom:'
            else if j <= 20
              message += ':hibiscus:'
          if ~~dayInfoArray[i].getDayData().dateCnt >= 20
            message += '・・・'

          message += '     '
          message += trendLastWeek()

      callback()
  ], () ->
    message = message.replace /\s+$/, ''
    mainCallBack(message)
  )

contributionsCalendar = (mainCallBack) ->
  # color
  # less #eeeeee -> #d6e685 -> #8cc665 -> #44a340 -> #1e6823 more
  # icon
  # less  ∴ -> ○ -> ⦿ -> ◆ -> ★ more

  async.waterfall( [
    (callback) ->
      calendarArray = []
      day = new Date(dayInfoArray[0].getDayData().date)
      day = day.getDay()
      for d in [0 ... day]
        calendarArray.push '`※`'

      for v, i in dayInfoArray
        switch v.getDayData().color
          when '#eeeeee'
            calendarArray.push '`∴`'
          when '#d6e685'
            calendarArray.push '`◯`'
          when '#8cc665'
            calendarArray.push '`◎`'
          when '#44a340'
            calendarArray.push '`◆`'
          when '#1e6823'
            calendarArray.push '`★`'
      callback null, calendarArray
    ,
    (arr, callback) ->
      lines = ['','','','','','','']
      days = ['`S`','`M`','`T`','`W`','`T`','`F`','`S`']
      message = ""
      message += '>>> --- _*Contributions*_ --- \n'
      for v, i in arr
        if i < 7
          lines[i] += (days[i] + ' ')
          lines[i] += (arr[i] + ' ')
        else
          lines[i%7] += (arr[i] + ' ')
      for v in lines
        message += (v + '\n')
      message += '`Less   ∴  <  ◯  <  ◎  <  ◆  <  ★   More `\n'
      callback null, arr, message
  ], (err, arr, message) ->
    mainCallBack message
  )

module.exports = (robot) ->
  parseContributions(robot, () ->)

  # notification   
  new cron '00 00 15,21,23 * * *', () =>
    parseContributions(robot, ()->
      if dayInfoArray[dayInfoArray.length-1].getDayData().dateCnt is '0'
        robot.send {room: '#bot-debug'},  "Please grow grass :("
    )
  , null, true, 'Asia/Tokyo'

  # base information
  robot.hear /info$/i, (msg) ->
    msg.send ">>> Year of contributions: #{baseInfoObj.all} total #{baseInfoObj.allPeriod}\nLongest streak: #{baseInfoObj.longestStreak} days\nCurrent streak: #{baseInfoObj.currentStreak} days #{baseInfoObj.currentStreakPeriod}"

  # trend of this week
  robot.hear /trend$/i, (msg) ->
    trendThisWeek((str) ->
      msg.send str
    )

  # refresh data
  robot.hear /reload$/i, (msg) ->
    parseContributions(robot, ()->
      msg.send "update complete!"
    )

  robot.hear /cal$/i, (msg) ->
    contributionsCalendar((str) ->
      msg.send str
    )