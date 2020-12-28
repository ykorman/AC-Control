import os
from flask import Flask, render_template, request, redirect, url_for, send_file, make_response

app = Flask(__name__)

@app.route('/',methods=('GET', 'POST'))
def index():
    if request.method == 'POST':
        resp = make_response(redirect(url_for('download')))
        list(map(lambda e: resp.set_cookie(e[0], e[1]), request.form.items()))
        return resp

    return render_template('ui.html')
