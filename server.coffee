bodyParser = require 'body-parser'
express    = require 'express'

app = express()

app.use bodyParser.urlencoded
  extended: true

app.get '/sofas', (req, res) ->
  throw new Error 'not implemented'

app.get '/sofas/:sofa', (req, res) ->
  throw new Error 'not implemented'


exports.listen = (callback) ->
  port = process.env.PORT
  app.listen port, callback
