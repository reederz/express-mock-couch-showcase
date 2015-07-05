nano = require 'nano'
Q    = require 'q'

class DAL
  constructor: (port, @database) ->
    @conn = nano("http://localhost:#{port}")

  # Returns a promise reseting database
  resetDatabase: (withSamples=false) ->
    docs = [@_sofaViews]
    if withSamples
      docs = docs.concat @_sofaSamples

    @_deleteDb()
      .then => @_createDb()
      .then => Q.all(docs.map (d) => @_insertDoc(d))

  # Returns a promise of sofas
  # If you provide the id- you'll get an array with a particular sofa in it
  getSofas: (id=null) ->
    params = {}
    params.key = id if id?

    @_view('sofas', 'all', params)
      .then (res) ->
        body = res[0]
        sofas = (row.value for row in body.rows)
        return sofas

  _sofaViews:
    _id: '_design/sofas'
    views:
      all:
        map: (doc) ->
          if doc.type is 'Sofa'
            emit doc._id, doc

  _sofaSamples: [
    {
      _id: 'sofa1'
      type: 'Sofa'
      name: 'Sofa1'
      price: 400
    }
    {
      _id: 'sofa2'
      type: 'Sofa'
      name: 'Sofa2'
      price: 300
    }
    {
      _id: 'sofa3'
      type: 'Sofa'
      name: 'Sofa3'
      price: 500
    }
  ]

  # Returns promise of creating database
  _createDb: ->
    d = Q.defer()
    @conn.db.create @database, d.makeNodeResolver()
    d.promise

  # Returns promise of deleting database
  _deleteDb: (ignoreMissing=true)->
    d = Q.defer()
    @conn.db.destroy @database, (err, res) ->
      err = null if err? and err.statusCode is 404 and ignoreMissing
      d.makeNodeResolver()(err, res)
    d.promise


  # Returns promise of inserting a doc
  _insertDoc: (doc) ->
    d = Q.defer()
    @conn.use(@database).insert doc, d.makeNodeResolver()
    d.promise


  # Returns promise of CouchDB view
  _view: (designDoc, view, params={}) ->
    d = Q.defer()
    @conn.use(@database).view designDoc, view, params, d.makeNodeResolver()
    d.promise


module.exports = DAL
