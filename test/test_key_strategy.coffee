assert      = require('assert')
main        = require('../src/index')
helper      = require('./helpers')()

# forks the Advice with a new keyStrategy when given an argument
helper.test ->
  console.log 'hi'
  oldStrategy = (arg0) -> arg0[0]
  strategy = (args...) -> JSON.stringify(args)
  cacher = main({keyStrategy: oldStrategy})
  jsonKeys = cacher.keyStrategy(strategy)
  assert.equal(oldStrategy, cacher.state.keyStrategy)
  assert.equal(strategy, jsonKeys.state.keyStrategy)

# returns the existing keyStrategy without an argument

helper.run()
