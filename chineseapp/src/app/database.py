from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.pool import QueuePool

db = SQLAlchemy(engine_options={"pool_size":10, "poolclass":QueuePool, "pool_pre_ping":True, "pool_recycle":3600})