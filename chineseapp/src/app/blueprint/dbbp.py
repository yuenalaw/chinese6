from flask import Blueprint, request

db_bp = Blueprint('db_bp', __name__,
                     template_folder='templates',
                     static_folder='static',
                     static_url_path='assets')