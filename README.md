# Cache Advice

by Matthew Lyon <matthew@lyonheart.us>

A node.js module for caching the results of functions that take callbacks.
The caching mechanism is pluggable, by default will use [lru-cache][]

## Example

    var cacher = require('cache-advice')()
      , reader = cacher.get(fs.readFile)
      ;

    setTimeout(function(){
      reader('README.md', 'utf8')
      // will pull the result from fs.readFile, store in cache
      // by default uses the first argument as the cache key
      }, 1000);

    setTimeout(function(){
      reader('README.md', 'utf8')
      // will check the cache first, if found will serve from that
      // fs.readFile will not get called
      }, 2000);

## Alternate Caching Modules

[lru-cache]:
