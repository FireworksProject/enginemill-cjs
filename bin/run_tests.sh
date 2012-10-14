#!/bin/bash
bindir="$(cd `dirname $0` && pwd)"
repo="$(dirname "$bindir")"

node_modules/.bin/mocha --compilers coffee:coffee-script "$repo/test/"
exit $?
