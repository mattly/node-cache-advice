REPORTER ?= dot

test: test-unit

test-unit:
	@NODE_ENV=test \
	  ./node_modules/.bin/mocha \
	  --compilers coffee:coffee-script \
	  --reporter $(REPORTER)

package.json:
	coffee package.coffee > package.json

build:
	coffee -c -o advice src/*.coffee

clean:
	rm -f advice/*
	rm -f package.json

.PHONY: test test-unit clean build

