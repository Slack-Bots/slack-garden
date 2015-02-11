# Let's grow many grass everyday !  

### Slack-garden will help you to fill the contributions of Github.  
This bot is used in slack.  

## Function
- [x] send message to Slack when you don't contribute today  
- [x] show basic data(e.g. 1 year total, Longest streak, Current streak...)    
- [x] show Contributions Calendar on Slack  
- [x] trend of this week  

## Keyword
- info  
![info](http://about-hiroppy.com/screenshot/slack-garden/info.png)  
- reload  
- trend  
![trend](http://about-hiroppy.com/screenshot/slack-garden/trend.png)  
- cal
![cal](http://about-hiroppy.com/screenshot/slack-garden/calendar.png)   
- url  
![url](http://about-hiroppy.com/screenshot/slack-garden/url.png)  

## Install and Setting
1. `$ git clone git@github.com:Slack-Bots/slack-garden.git`  
3. set Integrations of [Slack](https://slack.com/) and add Hubot  
4. deploy to [Heroku](https://www.heroku.com/) or others  
5. set options of Heroku  
```
$ heroku config:add NODE_USERNAME=<hogehoge>  
$ heroku config:add NODE_CHANNEL=<piyopiyo>  
$ heroku config:add HUBOT_SLACK_TOKEN=<xxxxxxxxxxxxxx>  
$ heroku config:add HEROKU_URL=<your application url>  
```

## License
MIT  
