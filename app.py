from flask import Flask, render_template
from forms import NameForm
from flask_wtf.csrf import CSRFProtect
from dotenv import load_dotenv
import os

load_dotenv()  # Load environment variables from .env

app = Flask(__name__)
app.config['SECRET_KEY'] = os.getenv("SECRET_KEY")  # Loaded securely from .env

csrf = CSRFProtect(app)

@app.route('/', methods=['GET', 'POST'])
def index():
    form = NameForm()
    if form.validate_on_submit():
        name = form.name.data
        return f"Hello, {name}!"
    return render_template('form.html', form=form)


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
