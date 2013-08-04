events = require('events')

isNothing = (thing) -> thing is null or thing is undefined
anyThing  = (things) -> things.length > 1 or not isNothing(things[0])

keyFor = (strategy, prefix, args...) ->
  prefix or= ''
  key = strategy?(args...) or "#{args[0]}"
  "#{prefix}#{key}"

setIfThing = (cache, key, callback) ->
  (err, result...) ->
    if not err and anyThing(result) then set(cache, key, result)
    callback(err, result...)

get = (cache, key, cb) -> cache.get(key, cb)
set = (cache, key, val, cb) ->
  done = (err, result) -> cb?()
  cache.set(key, val, done)
del = (cache, key, cb) ->
  done = (err, result) -> cb?()
  cache.del(key, done)

cloneState = (previous, next) ->
  next[key] = value for own key, value of previous when not next[key]
  next

class Advice extends events.EventEmitter
  constructor: (@state) ->
    super()
    @state.cache or= require('./lru')(@state.lru)
    @cache = @state.cache

  keyStrategy: (keyStrategy) ->
    if keyStrategy then new Advice(cloneState(@state, {keyStrategy}))
    else @state.keyStrategy

  updates: (fn) ->
    {cache, keyStrategy, prefix} = @state
    (args..., callback) ->
      key = keyFor(keyStrategy, prefix, args...)
      fn(args..., setIfThing(cache, key, callback))

  readThrough: (fn) ->
    {cache, keyStrategy, prefix} = @state
    (args..., callback) ->
      key = keyFor(keyStrategy, prefix, args...)
      handleCache = (err, result) ->
        if not isNothing(result) then callback(undefined, result...)
        else fn(args..., setIfThing(cache, key, callback))
      get(cache, key, handleCache)

  expires: (fn) ->
    {cache, keyStrategy, prefix} = @state
    (args..., callback) ->
      key = keyFor(keyStrategy, prefix, args...)
      del(cache, key)
      fn(args..., callback)

module.exports = (config={}) -> new Advice(config)
