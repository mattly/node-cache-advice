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

  get = (key, callback) ->
    advice.cache.get key, (err, result) ->
      error(err)
      callback(err, result)

  set = (key, value, callback) ->
    advice.cache.set key, value, (err, result) ->
      error(err)
      callback?(err, result)

  advice.set = (fn, keymaker) ->
    keymaker or= defaultKeyMaker
    (args..., callback) ->
      key = keymaker(args...)
      fn args..., (err, result...) ->
        if err then return callback(err, result...)
        if advice.shouldStore(result) then set(key, result)
        callback(err, result...)

  advice.get = (fn, keymaker) ->
    keymaker or= defaultKeyMaker
    (args..., callback) ->
      key = keymaker(args...)
      get key, (err, result) ->
        if result then return callback(undefined, result...)
        fn(args..., callback)

  advice.readThrough = (fn, keymaker) ->
    keymaker or= defaultKeyMaker
    (args..., callback) ->
      key = keymaker(args...)
      get key, (err, result) ->
        if result then return callback(undefined, result...)
        fn args..., (err, result...) ->
          if err then return callback(err, result...)
          if advice.shouldStore(result) then set(key, result)
          callback(err, result...)

  advice.del = (fn, keymaker) ->
    keymaker or= defaultKeyMaker
    (args..., callback) ->
      key = keymaker(args...)
      fn args..., (err, result...) ->
        if err then return callback(err, result...)
        cache.del(key, error)
        callback(err, result...)

  advice
