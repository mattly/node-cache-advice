# Cache Advice

by Matthew Lyon <matthew@lyonheart.us>

A javascript module for caching the results of functions that take callbacks in
the node [err, response] pattern. Useful for decorating functions that make slow
database calls, http requests, etc.

The caching mechanism is pluggable, by default will use [lru-cache][]. Other
stores:

- [redis][redis-advice]

Coming soon:

- memcached
- riak
- sql table

[lru-cache]: https://github.com/isaacs/node-lru-cache
[redis-advice]: https://github.com/mattly/node-cache-advice-redis

## Example

    var cacher = require('cache-advice')();
    var getter = cacher.readThrough(reallySlowDbQuery);

    // will call reallySlowDbQuery, store results in cache
    var now = Date.now();
    getter(params, function(err, result){
      console.log("took %d ms", Date.now() - now);
    });

    setTimeout(function(){
      var now = Date.now();
      // will check the cache first, if found will serve from that
      reader(params, function(err, result){
        console.log("took %d ms", Date.now() - now);
      });
      }, 2000);

# Public API

## cacheAdvice(state)

## Configuration

### advice.prefix(prefixStr)

- **prefix**: String. If given, forks the advice with a new prefix. If not
  given, returns the existing prefix.

### advice.appendPrefix(prefixStr)

- **prefix** (required): String. Forks the advice strategy, appending the given
  string to the current one.

### advice.keyStrategy(fn)

- **fn**: Function. If given, forks the advice with a new key generation
  strategy function. If not given, returns the existnig key generation strategy.
  The default function is:

      function(){ return Array.prototype.join.apply(arguments); }

  The function will receive all arguments to the function except the final
  callback argument.

## Function Decorators

Will augment a provided function that conforms to the node.js callback pattern
(that is, is called with [arg1, arg2, ..., callback] and calls the callback with
[err, result1, result2, ...]) with a strategy for managing a the results in
a cache. The arguments to the function are used to generate the cache key using
the prefix and strategies in the config, and the results are provided to the
actual cache as an array, typically to be serialized via JSON.

### advice.updates(fn)

Will call `fn` with provided arguments and update the cache key for the provided
arguments with the result.

### advice.readThrough(fn)

Will check the cache first. On a hit, will provide cached results. On a miss,
will call `fn` with provided arguments and update the cache key for the provided
arguments with the result.

### advice.expires(fn)

Will expire the cache key for the provided arguments, then call `fn` with them.

