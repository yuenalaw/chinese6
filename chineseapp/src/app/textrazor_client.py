from textrazor import TextRazor
from src.app.config import Config

text_razor_client = TextRazor(Config.TEXTRAZOR_API_KEY, extractors=["entities"])
