assert = require('chai').assert

advice = require('../src/index')

cacher = undefined

beforeEach ->
  cacher = advice()

fn = (args..., callback) ->
  process.nextTick ->
    result = (arg.toUpperCase() for arg in args)
    callback(undefined, result...)

describe "setting advice", ->
  describe "with a successful result", ->
    it "uses a default keygetter", (done) ->
      setCache = cacher.set(fn)
      setCache 'foo', 'bar', (err, result...) ->
        assert.deepEqual(cacher.cache.lru.get('foo'), ['FOO','BAR'])
        assert.deepEqual(result, ['FOO','BAR'])
        done()

    it "uses a provided keygetter", (done) ->
      setCache = cacher.set(fn, (args...) -> args.join(','))
      setCache 'foo', 'bar', (err, result...) ->
        assert.deepEqual(cacher.cache.lru.get("foo,bar"), ['FOO','BAR'])
        assert.deepEqual(result, ['FOO','BAR'])
        done()

  describe "shouldStore", ->
    it "does not cache a null result", (done) ->
      setCache = cacher.set((args..., callback) -> callback(undefined, null))
      setCache 'foo', (err, result) ->
        assert.isUndefined(cacher.cache.lru.get("foo"))
        assert.isNull(result)
        done()

    it "does not store an undefined result", (done) ->
      setCache = cacher.set((args..., callback) -> callback())
      setCache 'foo', (err, result) ->
        assert.isUndefined(cacher.cache.lru.get("foo"))
        assert.isUndefined(result)
        done()

  it "does not store errors", (done) ->
    setCache = cacher.set((args..., callback) -> callback(new Error()))
    setCache 'foo', (err, result) ->
      assert.isUndefined(cacher.cache.lru.get('foo'))
      assert.instanceOf(err, Error)
      done()

describe "getting advice", ->
  it "bypasses the decorated function on cache hits", (done) ->
    cacher.cache.lru.set('foo', ['BAR'])
    getCache = cacher.get(fn)
    getCache 'foo', (err, result...) ->
      assert.deepEqual(result, ['BAR'])
      done()

  it "calls the decorated function on cache misses", (done) ->
    getCache = cacher.get(fn)
    getCache 'foo', (err, result...) ->
      assert.deepEqual(result, ['FOO'])
      done()

  it "uses a provided keymaker", (done) ->
    cacher.cache.lru.set('foo,bar', ['FOOBAR'])
    getCache = cacher.get(fn, (a...) -> a.join(','))
    getCache 'foo', 'bar', (err, result...) ->
      assert.deepEqual(result, ['FOOBAR'])
      done()

  it "emits errors from the cache, does not pass them through", (done) ->
    getCache = cacher.get(fn)
    cacher.cache.get = (key, callback) -> callback(new Error())
    count = 0
    finish = ->
      count += 1
      if count is 2 then done()

    cacher.on 'error', (err) ->
      assert(err)
      finish()

    getCache 'foo', (err, result...) ->
      assert.isUndefined(err)
      assert.deepEqual(result, ['FOO'])
      finish()

  it "passes errors from the decorated function", (done) ->
    getCache = cacher.get((a..., cb) -> cb(new Error()))
    getCache (err, result...) ->
      assert.instanceOf(err, Error)
      done()

describe "deleting advice", ->
  it "does not remove the key from the cache on error", (done) ->
    cacher.cache.lru.set('foo', ['FOO'])
    delCache = cacher.del((a..., cb) -> cb(new Error()))
    delCache 'foo', (err, result) ->
      assert.instanceOf(err, Error)
      assert.deepEqual(cacher.cache.lru.get('foo'), ['FOO'])
      done()

  it "removes the key from the cache on success", (done) ->
    cacher.cache.lru.set('foo', ['FOO'])
    delCache = cacher.del(fn)
    delCache 'foo', (err, result...) ->
      assert.isUndefined(cacher.cache.lru.get('foo'))
      assert.deepEqual(result, ['FOO'])
      done()

  it "uses a provided keymaker", (done) ->
    cacher.cache.lru.set('foo,bar', ['FOO','BAR'])
    delCache = cacher.del(fn, (a...) -> a.join(','))
    delCache 'foo', 'bar', (err, result...) ->
      assert.isUndefined(cacher.cache.lru.get('foo,bar'))
      assert.deepEqual(result, ['FOO','BAR'])
      done()

  it "emits errors from the cache, does not pass them through", (done) ->
    cacher.cache.lru.set('foo,bar', ['FOO','BAR'])
    cacher.cache.del = (key, callback) -> callback(new Error())
    delCache = cacher.del(fn)
    count = 0
    finish = ->
      count += 1
      if count is 2 then done()
    cacher.on 'error', (err) ->
      assert.instanceOf(err, Error)
      finish()
    delCache 'foo', (err, result...) ->
      assert.isUndefined(err)
      assert.deepEqual(result, ['FOO'])
      finish()


