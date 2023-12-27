from ..model.models import db, UserSentence, VideoDetails
import json

class ModelRepository:
    
    def update_user_sentence(self, video_id: str, line_changed: int, user_sentence: json) -> None:
        """
        Update the user_sentence for a specific sentence.

        Parameters:
        video_id (str): The ID of the video.
        line_changed (int): The index of the sentence in the lesson_data.
        user_sentence (json): The new user sentence -- THROUGH YOUTUBEHELPER.
        """
        try:
            # ensure line changed is int
            line_changed = int(line_changed)
            # Get the UserSentence entry
            user_sentence_entry = db.session.query(UserSentence).filter_by(video_id=video_id, line_changed=line_changed).first()
            if user_sentence_entry is None:
                # Create a new UserSentence
                user_sentence_entry = UserSentence(video_id=video_id, line_changed=line_changed, user_sentence=user_sentence)
                db.session.add(user_sentence_entry)
                print(f"Created UserSentence for video_id {video_id}, and line_changed {line_changed}")
            else:
                # Update the user_sentence
                user_sentence_entry.user_sentence = user_sentence
                print(f"Updated UserSentence for video_id {video_id}, and line_changed {line_changed}")

            # Commit the changes
            db.session.commit()

        except Exception as e:
            print(f"An error occurred (updating UserSentence): {e}")
            db.session.rollback()
            raise
    
    def video_details_exists(self, id):
        return db.session.query(VideoDetails.id).filter_by(id=id).scalar() is not None

    def add_video_lesson_to_db(self, video_id, processed_transcript, keyword_to_images):
        
        print(f"On db side... Adding video to lesson. Vid id: {video_id}\n")

        try:
            # Delete any existing VideoDetails with the same video_id
            VideoDetails.query.filter_by(id=video_id).delete()

            # Create a new VideoDetails instance,
            video_details = VideoDetails(
                id=video_id,
                lesson_data=json.dumps(processed_transcript),  # Convert the list to a JSON string
                lesson_keyword_imgs=json.dumps(keyword_to_images)  # Convert the dictionary to a JSON string
            )

            # Add the new VideoDetails instance to the session
            db.session.add(video_details)

            # Commit the session to save the changes
            db.session.commit()
            print(f"Added VideoDetails for video_id {video_id}")
        except Exception as e:
            print(f"An error occurred while adding VideoDetails: {e}")
            db.session.rollback()
            raise