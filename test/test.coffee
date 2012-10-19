TOOLS = require 'test-tools'
T = TOOLS.test

describe 'Start', ->

    it 'should do something', T (done) ->
        @expectCount(1)
        @assert(true, 'true is ok')
        return done()

    return
