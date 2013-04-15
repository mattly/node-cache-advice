github = 'github.com/mattly/node-cache-advice'
tags = 'cache functional aspect-oriented-programming'.split(' ')
info =
  name: 'cache-advice'
  description: 'function decorators for caching'
  version: '0.0.6'
  author: 'Matthew Lyon <matthew@lyonheart.us>'
  keywords: tags
  tags: tags
  homepage: "https://#{github}"
  repository: "git://#{github}.git"
  bugs: "https://#{github}/issues"

  dependencies:
    'lru-cache': '2.2.x'

  devDependencies:
    # deal with it
    'coffee-script': '1.6.x'
    # test runner / framework
    mocha: '1.8.x'
    # assertions helper
    chai: '1.4.x'

  scripts:
    # preinstall
    # postinstall
    # poststart
    prepublish: "make build"
    # pretest
    test: "make test"

  main: 'index.js'
  engines: { node: '*' }

console.log(JSON.stringify(info, null, 2))


