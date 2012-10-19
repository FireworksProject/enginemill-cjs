# Enginemill CJS

A JavaScript file and module loader for web browsers.

Enginemill CJS is designed to be served from Node.js web frameworks like
[Enginemill](https://github.com/FireworksProject/enginemill) and
[Express](http://expressjs.com/).

* Bundle existing libraries like jQuery, jQuery plugins, and anything else that would be normally be loaded via a script tag.
* Include your own JavaScript libraries and modules.
* [CommonJS](http://en.wikipedia.org/wiki/CommonJS) compliant.
* Freely mix JavaScript and CoffeeScript modules and libraries.
* Bundle and minify scripts for static deployment.

## Installation
### Server
For use on your server, Enginemill CJS is designed to be installed by including
it in the package.json dependencies list for your web project.
Follow the [npm documentation for package.json](https://npmjs.org/doc/json.html)
if you don't already know how to do that.

Once you have it listed in the package.json for your project, just run

    npm install

from the root of your project.

### Command Line Tool
Enginemill CJS also comes with a command line tool for building and minifying a
JavaScript bundle for deployment as a static asset. This is ideal for usage on
a CDN.

If you are only interested in using the Command Line functionality of Enginemill CJS
and not the server side loader, then you can easily install it using

    sudo npm install -g enginemill-cjs

assuming you already have Node.js installed.

## Usage on a Server

To use the Enginemill CJS middleware in Express.js,
load it into your application like this:
```JavaScript
var PATH = require('path');

var EX = require('express')
  , ECJS = require('enginemill-cjs');

var app = EX();

app.use('/commonjs', ECJS.middleware({
    base: PATH.join(__dirname, 'commonjs')
}));
// Will capture requests to
// GET /commonjs/lib/jquery.js
// GET /commonjs/main.js
//
// The base path for this loader will be the result of
//
//     PATH.join(__dirname, 'commonjs')
//
// and all modules will be resolved off that path.
```

To do the same thing in Enginemill just mount it in your app.ini file:
```ini
[routes.commonjs]
paths=["/commonjs"]
module=plugins.enginemill_cjs
```

Now, suppose you have a `commonjs/` directory in the root of your application which looks like this:

    ./commonjs/
    |-- do-a.js
    |-- get-b.js
    |-- main.coffee
    |-- lib/
        |-- jquery-1.8.2.min.js
        |-- jquery-slideshow.min.js

where the contents of the files are:

`commonjs/do-a.js`

    exports.foo = function () {
        return 'foo bar';
    };

`commonjs/grade-b.js`

    exports.bar = 'foo bar';

`commonjs/lib/jquery-1.8.2.min.js`

    // minimized jQuery code

`commonjs/lib/jquery-slideshow.min.js`

    // minimized slideshow plugin code

`commonjs/main.coffee`

    "include ./lib/jquery-1.8.2.min.js"
    "include ./lib/jquery-slideshow.min.js"

    A = require './do-a'
    B = require './get-b'

    $ ->
        # Application initialization
        $('body').find('article').slideshow()

        if A.foo() isnt B.bar then alert('no match!')
        return

And, suppose you had this snippet of HTML served to the browser:

```HTML
<script type="text/javascript" src="/commonjs/main.coffee"></script>

```

It would call Enginemill CJS, which would read `commonjs/main.coffee`, include
both `commonjs/lib/jquery-1.8.2.min.js` and `commonjs/lib/jquery-slideshow.min.js`,
before requiring `commonjs/do-a.js` and `commonjs/get-b.js`, so the resulting file
sent to the browser will be:

```JavaScript
// code read from jquery-1.8.2.min.js
// code read from jquery-slideshow.min.js

// Enginmill CJS module loader code

module.declare('/do-a', function (require, exports) {
    exports.foo = function () {
        return 'foo bar';
    };
});

module.declare('/get-b', function (require, exports) {
    exports.bar = 'foo bar';
});

module.declare('/main', function (require, exports) {
    var A = require('./do-a'), B = require('./get-b');

    $(function () {
        $('body').find('article').slideshow();

        if (A.foo() !== B.bar) {
            alert('no match!');
        }
        return;
    });
});

require('main');
```

## Command Line Usage
You could build the same bundle using the command line tool for static deployment.
This is great for deploying your JavaScript bundles out on a CDN.

If you installed Enginemill CJS for use on your Node.js webserver, then you can
build the JavaScript bundle above with this command in your terminal:

    ./node_modules/.bin/enginemill-cjs \
        --source commonjs/main.coffee \
        --target /tmp/main-0.2.3.min.js.gzip \
        --min
        --compress

Or, if you installed Enginemill CJS as a command line tool globally then you
can do the same thing with this command:

    enginemill-cjs \
        --source commonjs/main.coffee \
        --target /tmp/main-0.2.3.min.js.gzip \
        --min
        --compress

You can run `enginemill-cjs --help` to learn more.


Copyright and License
---------------------
Copyright: (c) 2012 by The Fireworks Project (http://www.fireworksproject.com)

Unless otherwise indicated, all source code is licensed under the MIT license. See MIT-LICENSE for details.
