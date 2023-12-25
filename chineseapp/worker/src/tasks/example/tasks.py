from ...celery_app import celery
import logging

logger = logging.getLogger(__name__)

@celery.task(name="example_task")
def example_task(input1:int, input2:int):
    return "Value is " + str(input1 + input2)