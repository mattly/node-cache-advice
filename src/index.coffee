events = require('events')

isNothing = (thing) -> thing is null or thing is undefined
isThing   = (thing) -> not isNothing(thing)
anyThing  = (things) ->
  idx = 0
  idx += 1 while not things[idx] and idx < things.length
  idx isnt things.length

keyFor = (strategy, prefix, args...) ->
  prefix or= ''
  key = strategy?(args...) or "#{args[0]}"
  "#{prefix}#{key}"

get = (cache, key, cb) -> cache.get(key, cb)
set = (cache, key, val, cb) ->
  done = (err, result) -> cb?()
  cache.set(key, val, done)
del = (cache, key, cb) ->
  done = (err, result) -> cb?()
  cache.del(key, done)

class Advice extends events.EventEmitter
  constructor: (@state) ->
    super()
    @state.cache or= require('./lru')(@state.lru)
    @cache = @state.cache

  readThrough: (fn) ->
    {cache, keyStrategy, prefix} = @state
    (args..., callback) ->
      key = keyFor(keyStrategy, prefix, args...)
      handleResult = (err, result...) ->
        if not err and anyThing(result) then set(cache, key, result)
        callback(err, result...)
      handleCache = (err, result) ->
        if isThing(result) then callback(undefined, result...)
        else fn(args..., handleResult)
      get(cache, key, handleCache)

  expires: (fn) ->
    {cache, keyStrategy, prefix} = @state
    (args..., callback) ->
      key = keyFor(keyStrategy, prefix, args...)
      del(cache, key)
      fn(args..., callback)

module.exports = (config={}) -> new Advice(config)

  # errNotifier = (callback) ->
  #   (err, result) ->
  #     if err then advice.emit('error', err)
  #     callback?(err, result)

  # advice.set = (fn, keymaker) ->
  #   keymaker or= defaultKeyMaker
  #   (args..., callback) ->
  #     key = keymaker(args...)
  #     fn args..., (err, result...) ->
  #       if err then return callback(err, result...)
  #       if advice.shouldStore(result) then set(key, result)
  #       callback(err, result...)
