from src.app.factory import create_app
from src.app.database import db
from src.app.models import MySqlModel

app = create_app()

# Database config
db.init_app(app)

with app.app_context():
    db.create_all()