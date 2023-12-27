from ...shared.repository.MySqlAlchemyRepo import ModelRepository
from .SRSHelper import SRSHelper
from datetime import date, timedelta
import json

class ModelService:
    model_repository = ModelRepository()
    SRS_helper = SRSHelper()

    def video_exists(self, vid_id):
        return self.model_repository.video_details_exists(vid_id)

    def create_video_lesson(self, id, processed_transcript, keyword_to_images):
        try:
            processed_transcript = json.loads(processed_transcript)
            keyword_to_images = json.loads(keyword_to_images)
            self.model_repository.add_video_lesson_to_db(id, processed_transcript, keyword_to_images)
            print(f"Successfully added video to db!")
            return True
        except Exception as e:
            print(f"In model service; error occured in the repo when creating video lesson: {e}")
            raise
    
    def update_user_sentence(self, video_id, line_changed, new_sentence):
        """
        new sentence has the same json structure as old, going through youtube helper and getting pinyin etc
        """
        try:
            print(f"obtained new sentence is: {new_sentence}")
            self.model_repository.update_user_sentence(video_id, line_changed, new_sentence)
            print(f"Updated user sentence")
        except Exception as e:
            print(f"In model service; error occured adding new user sentence: {e}")
            raise