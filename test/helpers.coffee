module.exports = ->
  out = {}
  out.assertions = []
  out.test = (fn) -> out.assertions.push(fn)
  out.run = ->
    if out.assertions.length is 0 then console.log("OK")
    else process.nextTick ->
      nextFn = out.assertions.shift()
      if nextFn.length > 0 then nextFn(out.run)
      else
        nextFn()
        out.run()

  out.cache = ->
    store = []
    get = (key, cb) -> cb(null, store[key])
    set = (key, val, cb) -> store[key] = val; cb?()
    del = (key, cb) -> delete store[key]; cb?()
    {store, get, set, del}
  out.vals = {foo:'foo',bar:'bar',baz:'baz'}
  out.fn = (key, cb) -> cb(null, out.vals[key])
  out.errFn = -> throw new Error("Should Not Get Here")

  out
