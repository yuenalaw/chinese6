import serpapi
from src.app.config import Config

serpapi_client = serpapi.Client(api_key=Config.GOOGLE_IMG_API_KEY)