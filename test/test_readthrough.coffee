assert      = require('assert')
main        = require('../src/index')
helper      = require('./helpers')()
{test, cache} = helper


# returns cache result on hit
test (done) ->
  cacher = main({cache: cache()})
  expected = ['bar']
  cacher.cache.store['foo'] = expected
  getter = cacher.readThrough(helper.errFn)
  getter 'foo', (err, result...) ->
    assert.deepEqual(expected, result)
    done()

# stores truthy results from function
test (done) ->
  cacher = main({cache: cache()})
  getter = cacher.readThrough(helper.fn)
  getter 'foo', (err, result...) ->
    assert.deepEqual([helper.vals['foo']], result)
    assert.deepEqual([helper.vals['foo']], cacher.cache.store['foo'])
    done()

# does not store falsy results from function
test (done) ->
  cacher = main({cache:cache()})
  getter = cacher.readThrough(helper.fn)
  getter 'bee', (err, result) ->
    assert.equal(null, result)
    assert.equal(null, cacher.cache.store['bee'])
    done()

# does not store result on function error
test (done) ->
  cacher = main({cache:cache()})
  getter = cacher.readThrough((args, cb) -> cb(new Error(), 'foo'))
  getter 'foo', (err, result...) ->
    assert(err instanceof Error)
    assert.equal(null, cacher.cache.store['foo'])
    done()

# uses the current prefix
test (done) ->
  cacher = main({cache:cache(), prefix:'prefix:'})
  getter = cacher.readThrough(helper.errFn)
  cacher.cache.store['prefix:foo'] = ['foo']
  getter 'foo', (err, result...) ->
    assert.deepEqual(['foo'], result)
    done()

# uses the current key strategy
test (done) ->
  keyStrategy = (args...) -> JSON.stringify(args)
  cacher = main({cache:cache(), keyStrategy})
  getter = cacher.readThrough(helper.errFn)
  cacher.cache.store['["foo","bar"]'] = ["foobar"]
  getter 'foo', 'bar', (err, result...) ->
    assert.deepEqual(['foobar'], result)
    done()

helper.run()
