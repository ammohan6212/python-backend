from flask import Flask, render_template, redirect, url_for
from forms import NameForm
from flask_wtf.csrf import CSRFProtect
import os 

app = Flask(__name__)
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'fallback-secret') 
csrf = CSRFProtect(app)

@app.route('/', methods=['GET', 'POST'])
def index():
    form = NameForm()
    if form.validate_on_submit():
        # Safe to handle POST input here
        name = form.name.data
        return f"Hello, {name}!"
    return render_template('form.html', form=form)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
