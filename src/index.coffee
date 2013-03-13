events = require('events')

module.exports = (config={}) ->

  if config.cache
    cache = config.cache
  else
    cache = require('./lru')(config.lru)

  defaultKeyMaker = (args...) -> "#{args[0]}"

  shouldStore = (args) ->
    store = false
    store = true for arg in args when arg
    store

  advice = new events.EventEmitter()
  error = (err) ->
    if err then advice.emit('error', err)
  advice.cache = cache
  advice.shouldStore = shouldStore

  advice.set = (fn, keymaker) ->
    keymaker or= defaultKeyMaker
    (args..., callback) ->
      key = keymaker(args...)
      fn args..., (err, result...) ->
        if err then return callback(err, result...)
        if advice.shouldStore(result)
          cache.set key, result, (err) ->
        callback(err, result...)

  advice.get = (fn, keymaker) ->
    keymaker or= defaultKeyMaker
    (args..., callback) ->
      key = keymaker(args...)
      cache.get key, (err, result) ->
        error(err)
        if result then return callback(err, result...)
        fn(args..., callback)

  advice.del = (fn, keymaker) ->
    keymaker or= defaultKeyMaker
    (args..., callback) ->
      key = keymaker(args...)
      fn args..., (err, result...) ->
        if err then return callback(err, result...)
        cache.del(key, error)
        callback(err, result...)

  advice
