lru = require('lru-cache')

callbackify = (fn, context) ->
  (args..., callback) ->
    try
      result = fn.apply(context, args)
      callback(undefined, result)
    catch e
      callback(e)

module.exports = (config) ->
  config or= 50
  cache = {lru: lru(config)}

  for method in ['get','set','del']
    cache[method] = callbackify(cache.lru[method], cache.lru)
  cache

