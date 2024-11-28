---
layout: post
title: HTML5 ajax file upload with flask
date: 2013-06-26 15:17:00
comments: true
tags: [ jinja2, flask, programming, python ]
---

## Making web uploads less painfull

For one of my current Flask projects i want to have a nice looking and easy to use file upload form. 
That means no `input type="file"` form field where i have to select each file and the upload it on at a time.
I came across [this nice tutorial](http://tutorialzine.com/2011/09/html5-file-upload-jquery-php) for a HTML5/jquery file uploader, but the backend is written in PHP.
So I decided to try to get this working with Flask and it was easier as I supposed :-)

<!--more-->

## The server side

This is the server side code:

```python
#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
from datetime import datetime
from flask import Flask, render_template, jsonify, redirect, url_for, request

app = Flask(__name__)
app.config.from_object(__name__)
app.config['UPLOAD_FOLDER'] = 'uploads'

ALLOWED_EXTENSIONS = ['txt', 'pdf', 'png', 'jpg', 'jpeg', 'gif']

@app.route("/")
def index():
    return render_template("index.html")

@app.route('/upload', methods=['POST'])
def upload():
    if request.method == 'POST':
        file = request.files['file']
        if file and allowed_file(file.filename):
            now = datetime.now()
            filename = os.path.join(app.config['UPLOAD_FOLDER'], "%s.%s" % (now.strftime("%Y-%m-%d-%H-%M-%S-%f"), file.filename.rsplit('.', 1)[1]))
            file.save(filename)
            return jsonify({"success":True})

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS

if __name__ == "__main__":
    app.run(debug=True)
```

The code is very simple, the route / displays the template with the dropzone for the files.
The /upload route takes the sent POST data (the files).

## The client side

The index template:

```html
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8" />
        <title>HTML5 / jQuery</title>
        <link rel="stylesheet" href="static/css/styles.css" />
        <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/2.0.2/jquery.min.js"></script>
        <script type="text/javascript" src="static/js/jquery.filedrop.js"></script>
        <script type="text/javascript" src="static/js/upload.js"></script>
    </head>
    <body>
        <div id="dropbox">
            <span class="message">Drop images here to upload.</span>
        </div>
    </body>
</html>
```

And the important part of the upload.js:

```js
dropbox.filedrop({
    paramname: 'file',
    maxfiles: 10,
    maxfilesize: 5,
    url: '/upload',
    uploadFinished:function(i,file,response){
        $.data(file).addClass('done');
    }
})
```
    
It's important that `paramname: 'file'` in upload.js is equal to the key in app.py `file = request.files['file']`. Otherwise you will get a `Error 400 Bad Request`.
Also, the `url` parameter in upload.js has to be equal to the defined route in app.py.

When you drag&drop files to the dropzone, they will be saved in /uploads. I decided to replace the filename by the upload date, because otherwise the widespread IMG_XXX.JPG filenames possibly overwrite a already uploaded file.

And that's it :-)

You can find a working example on my [GitHub account](https://github.com/Bouni/HTML5-jQuery-Flask-file-upload)
