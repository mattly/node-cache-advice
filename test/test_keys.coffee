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

# prefix/1 forks the Advice with a new prefix
helper.test ->
  [oldPrefix, newPrefix] = ["foo:", "bar."]
  cacher = main({prefix: oldPrefix})
  barSpace = cacher.prefix(newPrefix)
  assert.equal(oldPrefix, cacher.state.prefix)
  assert.equal(newPrefix, barSpace.state.prefix)

# prefix/0 returns the existing prefix
helper.test ->
  prefix = "foo."
  cacher = main({prefix})
  assert.equal(prefix, cacher.prefix())

# appendPrefix/1 forks the Advice with an appended prefix.
helper.test ->
  prefix = "foo."
  segment = "bar."
  cacher = main({prefix})
  barSpace = cacher.appendPrefix(segment)
  assert.equal(prefix, cacher.state.prefix)
  assert.equal("#{prefix}#{segment}", barSpace.state.prefix)

helper.run()
