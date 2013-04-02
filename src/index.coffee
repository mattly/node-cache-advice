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
  advice.cache = cache
  advice.shouldStore = shouldStore

  errNotifier = (callback) ->
    (err, result) ->
      if err then advice.emit('error', err)
      callback?(err, result)

  get = (key, callback) ->
    advice.cache.get(key, errNotifier(callback))

  set = (key, value, callback) ->
    advice.cache.set(key, value, errNotifier(callback))

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
        cache.del(key, errNotifier())
        callback(err, result...)

  advice
