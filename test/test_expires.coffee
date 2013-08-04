assert      = require('assert')
main        = require('../src/index')
helper      = require('./helpers')()
{test, cache} = helper

# removes the key from the cache before calling the function
test (done) ->
  cacher = main({cache: cache()})
  cacher.cache.store['foo'] = ['bee']
  expirer = cacher.expires(helper.fn)
  expirer 'foo', (err, result...) ->
    assert.deepEqual([helper.vals['foo']], result)
    assert.equal(null, cacher.cache.store['foo'])
    done()

helper.run()
