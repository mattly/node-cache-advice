github = 'github.com/mattly/node-cache-advice'
tags = 'cache functional aspect-oriented-programming'.split(' ')
base =
  name: 'cache-advice'
  description: 'function decorators for caching'
  version: '0.1.0'
  author: 'Matthew Lyon <matthew@lyonheart.us>'
  keywords: tags
  tags: tags
  homepage: "https://#{github}"
  repository: "git://#{github}.git"
  bugs: "https://#{github}/issues"

package_json =
  dependencies:
    'lru-cache': '2.2.x'

  devDependencies:
    # deal with it
    'coffee-script': '1.6.x'

  scripts:
    prepublish: "./node_modules/.bin/coffee -c -o advice src/*.coffee"
    test: "./node_modules/.bin/coffee test/run.coffee"

  main: 'index.js'
  engines: { node: '*' }

make = (extend={}) ->
  out = {}
  for obj in [base, extend]
    for key, value of obj
      out[key] = value
  JSON.stringify(out, null, 2)

fs = require('fs')
fs.writeFileSync('package.json', make(package_json))

