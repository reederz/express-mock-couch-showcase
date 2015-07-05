bodyParser = require 'body-parser'
express    = require 'express'
DAL        = require './dal'

dal = new DAL(process.env.COUCH_PORT, process.env.DATABASE)
app = express()

app.use bodyParser.urlencoded
  extended: true

app.get '/sofas', (req, res) ->
  dal.getSofas()
    .then (sofas) ->
      res.json(sofas)
    .fail (err) -> res.status(err.statusCode).send()

app.get '/sofas/:sofa', (req, res) ->
  dal.getSofas(req.params.sofa)
    .then (sofas) ->
      if sofas.length isnt 1
        res.status(404).send()
      else
        res.json(sofas[0])
    .fail (err) -> res.status(err.statusCode).send()


exports.listen = (callback) ->
  port = process.env.PORT
  app.listen port, callback
