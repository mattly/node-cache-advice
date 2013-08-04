assert      = require('assert')
main        = require('../src/index')
helper      = require('./helpers')()
{test, cache} = helper

# stores truthy results from function
test (done) ->
  cacher = main({cache: cache()})
  cacher.cache.store['foo'] = 'notfoo'
  getter = cacher.updates(helper.fn)
  getter 'foo', (err, result...) ->
    assert.deepEqual([helper.vals['foo']], result)
    assert.deepEqual([helper.vals['foo']], cacher.cache.store['foo'])
    done()

# does not store falsy results from function
test (done) ->
  cacher = main({cache:cache()})
  getter = cacher.updates(helper.fn)
  getter 'bee', (err, result) ->
    assert.equal(null, result)
    assert.equal(null, cacher.cache.store['bee'])
    done()

# does not store result on function error
test (done) ->
  cacher = main({cache:cache()})
  getter = cacher.updates((args, cb) -> cb(new Error(), 'foo'))
  getter 'foo', (err, result...) ->
    assert(err instanceof Error)
    assert.equal(null, cacher.cache.store['foo'])
    done()

helper.run()
