'use strict'

fs           = require 'fs'
cheerio      = require 'cheerio'
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

class baseInfo
  constructor: ->
    @baseObj = {}
  calc: ->
    @baseObj.all           = 0 # Year of contributions
    @baseObj.longestStreak = 0
    @LongestStreakArray    = []
    @baseObj.currentStreak = 0
    @CurrentStreakFlag     = false

    for i in [dayInfoArray.length-1 .. 0]
      @baseObj.all += ~~dayInfoArray[i].getDayData().dateCnt
      #console.log dayInfoArray[i].getDayData().dateCnt
      if dayInfoArray[i].getDayData().dateCnt isnt '0'
        # current streak
        if @CurrentStreakFlag is false
          @baseObj.currentStreak++

        # long streak
        @baseObj.longestStreak++
      else
        if i isnt dayInfoArray.length-1
          @CurrentStreakFlag = true
        @LongestStreakArray.push @baseObj.longestStreak
        @baseObj.longestStreak = 0

    @baseObj.longestStreak = Math.max.apply null, @LongestStreakArray
    baseInfoObj = @baseObj


class accessApi
  username = "abouthiroppy"
  url      = "https://github.com/users/#{username}/contributions"
  constructor:(robot) ->
    @robot = robot
  parseContributions: ->
    @robot.http(url)
    .get() (err, res, body) ->
      $ = cheerio.load body
      dayInfoArray = []
      #cnt = 0 # debug
      $('svg > g > g > rect').each(()->
        day = $(@)
        dayInfoArray.push(new dayInfo(day))
        #console.log day.attr 'data-date'
        #cnt++
      )
      #console.log "cnt: ",cnt
      base = new baseInfo()
      base.calc()

module.exports = (robot) ->
  date  = new Date
  today = date.getFullYear().toString() + ('0' + (date.getMonth() + 1).toString()).slice(-2) + ('0' + date.getDate().toString()).slice(-2)
  api   = new accessApi robot
  api.parseContributions()

  # notification 
  # debug
  # new cron '* * * * * *', () =>
  #   robot.send {room: "#bot-debug"}, "test3"
  # , null, true, "Asia/Tokyo"
  
  new cron '00 00 21,23 * * *', () =>
    date  = new Date
    today = date.getFullYear().toString() + ('0' + (date.getMonth() + 1).toString()).slice(-2) + ('0' + date.getDate().toString()).slice(-2)
    robot.send {room: '#bot-debug'}, "debug #{today}"
  , null, true, 'Asia/Tokyo'

  robot.respond /info$/i, (msg) ->
    msg.send "Year of contributions: #{baseInfoObj.all}\nLongest streak: #{baseInfoObj.longestStreak}\nCurrent streak: #{baseInfoObj.currentStreak}"

  robot.respond /reload$/i, (msg) ->
    api.parseContributions()
    # return complete message