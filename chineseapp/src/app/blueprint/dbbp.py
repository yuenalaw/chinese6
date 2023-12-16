from flask import Blueprint, request
from src.app.helpers.ModelHelper import ModelService

db_bp = Blueprint('db_bp', __name__,
                     template_folder='templates',
                     static_folder='static',
                     static_url_path='assets')

model_service = ModelService()
