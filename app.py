from flask import Flask, render_template, redirect, url_for
from forms import NameForm
from flask_wtf.csrf import CSRFProtect

app = Flask(__name__)
csrf = CSRFProtect(app)

@app.route('/', methods=['GET', 'POST'])
def index():
    form = NameForm()
    if form.validate_on_submit():
        name = form.name.data
        return f'Hello, {name}!'
    return render_template('form.html', form=form)

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=5000)
