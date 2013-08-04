assert      = require('assert')
main        = require('../src/index')
helper      = require('./helpers')()

# .keyStrategy/1 forks the Advice with a new keyStrategy
helper.test ->
  oldStrategy = (arg0) -> arg0[0]
  strategy = (args...) -> JSON.stringify(args)
  cacher = main({keyStrategy: oldStrategy})
  jsonKeys = cacher.keyStrategy(strategy)
  assert.equal(oldStrategy, cacher.state.keyStrategy)
  assert.equal(strategy, jsonKeys.state.keyStrategy)

# keyStrategy/0 returns the existing keyStrategy
helper.test ->
  keyStrategy = (arg0) -> arg0[0]
  cacher = main({keyStrategy})
  assert.equal(keyStrategy, cacher.keyStrategy())

helper.run()
