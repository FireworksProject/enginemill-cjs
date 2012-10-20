FS = require 'fs'
PATH = require 'path'
EventEmitter = require('events').EventEmitter

COFFEE = require 'coffee-script'


exports.loadAll = (aBase, aMain, aCallback) ->
    # included script paths that still need to be loaded
    scriptsToLoad = []

    # required module paths that still need to be loaded
    # initialized with the main module
    modulesToLoad = [exports.module(aBase, aMain)]
    loaded = {}

    # Set the return value
    rv = {scripts: [], modules: []}

    loadOne = ->
        exports.load module.base, module.id, (err, text) ->
            if err
                emit('warning', err)
                if err.code is 'FORBIDDEN' then return aCallback(err)

            if (err or not text) and module.id is aMain
                err = new Error("main module '#{aMain}' could not be loaded")
                err.code = 'NOTFOUND'
                return aCallback(err)

            dirname = PATH.dirname(module.id)
            basepath = module.base

            scriptDeps = findScriptDependencies(text).map (id) ->
                id = PATH.resolve(dirname, id)
                return exports.script(basepath, id)

            return
        return

    return


exports.createModule = (aId) ->
    return


exports.createScript = (aId) ->
    return


exports.load = (aBase, aId, aCallback) ->
    exports.readFile aBase, aId, (err, text) ->
        if err then return aCallback(err)

        dirname = PATH.dirname(aId)

        scripts = exports.findScriptDependencies(text).map (includePath) ->
            id = PATH.resolve(dirname, includePath)
            return exports.createScript(id)

        modules = exports.findModuleDependencies(text).map (requiredPath) ->
            id = PATH.resolve(dirname, requiredPath)
            return exports.createModule(id)

        aCallback({
            dependencies: scripts.concat(modules)
            text: text
        })
        return
    return


exports.readFile = (aBase, aId, aCallback) ->
    try
        abspath = exports.findFile(aBase, aId)
    catch err
        aCallback(err)

    if not abspath then return aCallback()

    FS.readFile abspath, 'utf8', (err, text) ->
        if err then return aCallback(err)

        if /\.coffee$/.test(abspath)
            try
                text = COFFEE.compile(text, {bare: yes})
            catch csError
                text = exports.error2source(csError)

        return aCallback(null, text)
    return


exports.findFile = (aBase, aId) ->
    # TODO: make this operation cross platform
    abspath = PATH.join(aBase, aId)

    # Make sure the .join() operation does not allow the caller to access files
    # outside the base directory
    if abspath.indexOf(aBase) isnt 0
        err = new Error("insecure module path")
        err.code = 'FORBIDDEN'
        throw err

    # scripts end in either .js or .coffee
    if /\.js$/.test(abspath) or /\.coffee$/.test(abspath)
        if PATH.existsSync(abspath) then return abspath

    # but modules must not have a file extension, so we have to append the
    # extension and test for existance
    for ext in ['js', 'coffee']
        abspath = abspath + '.' + ext
        if PATH.existsSync(abspath) then return abspath
    return


# Public Find and parse "require('foo/bar')" statements from a text.
#
# aText - The String to search
#
# Returns an Array of path names
exports.findModuleDependencies = do ->
    # cache the regex used to find calls to require
    requireX = /(?:^|[^\w\$_.])require\s*\(\s*("[^"\\]*(?:\\.[^"\\]*)*"|'[^'\\]*(?:\\.[^'\\]*)*')\s*\)/g

    fn = (aText) ->
        rv = []
        while match = requireX.exec(aText)
            rv.push(trimQuotes(match[1]))
        return rv

    return fn


# Public: Find and parse "include 'foo/bar.js'" sections from a text.
#
# aText - The String to search
#
# Returns an Array of path names
exports.findScriptDependencies = (aText) ->
    rv = []
    lines = aText.split(/\n/)

    for line in lines
        firstChar = line.charAt(0)
        if firstChar is '"' or firstChar is "'"
            line = trimQuotes(line)
            parts = line.split(' ')
            if parts.shift() is 'include'
                rv.push(parts.shift())
    return rv


# Internal: Remove leading and trailing quotes ('"' and "'").  This function
# will not remove multiple leading or trailing quotes.
#
# aString - The String to trim.
#
# Returns a String with the leading and trailing quotes removed.
trimQuotes = (aString) ->
    return aString.replace(/^[\'\"]+/, '').replace(/[\'\"\;]+$/, '')


# Public: Encode an Error object into a JavaScript text that will execute and
# throw an error when it reaches the web browser.
#
# aError - The Error object to encode.
#
# Returns a String which is the JavaScript source code representing aError.
exports.error2source = (aError) ->
    src = """;(function(){
    var e=new Error(#{JSON.stringify(aError.message)});
    e.name='#{aError.name}';
    e.stack=#{JSON.stringify(aError.stack)};
    throw e;}());
    """
    return src
