from src.app.repository.MySqlAlchemyRepo import ModelRepository

class ModelService:
    model_repository = ModelRepository()

    def video_exists(self, vid_id):
        return False

    def create_video_lesson(self, youtube_id, processed_transcript, keyword_to_images):
        try:
            self.model_repository.add_video_lesson_to_db(youtube_id, processed_transcript, keyword_to_images)
            print(f"Successfully added video to db!")
            return True
        except Exception as e:
            print(f"In model service; error occured in the repo when creating video lesson: {e}")
            return False