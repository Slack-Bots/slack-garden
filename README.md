# Let's grow many grass everyday !  

### Slack-garden will help you to fill the contributions of Github.  
This bot is used in slack.  

## Function
- [x] send message to Slack when you don't contribute today  
- [x] show basic data(e.g. 1 year total, Longest streak, Current streak...)    
- [ ] compare oneself with other people    
- [ ] show Contributions Calendar on Slack  
- [x] trend of this week  

## Keyword
- info  
- reload  
- trend  

## Install and Setting
1. `$ git clone git@github.com:Slack-Bots/slack-garden.git`  
2. `$ npm install`  
3. change a value of 'username'(the 10 line) in 'scripts/app.coffee'  
username = 'your name'  
4. set Integrations of [Slack](https://slack.com/) and add Hubot  
5. deploy to [Heroku](https://www.heroku.com/) or others  
6. set options of Heroku  
`$ heroku config:add HUBOT_SLACK_TOKEN=xxxxxxxxxxxxxx`  
`$ heroku config:add HEROKU_URL=<your application url>`  
`$ heroku config:add HEROKU_SLACK_BOTNAME=Landscaper`  
`$ heroku config:add HUBOT_SLACK_CHANNELS=<channel name>`  
`$ heroku config:add HUBOT_SLACK_TEAM=<your team name>`    

## License
MIT  