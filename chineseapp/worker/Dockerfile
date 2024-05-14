# pull official base image
#FROM python:3.9-slim
FROM stanfordnlp/stanza:with-python3.9
# FROM arm64v8/python -- for macos

# set work directory
ARG PROJECT_ROOT=/app
WORKDIR ${PROJECT_ROOT}

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PYTHONPATH /usr/src/app:$PYTHONPATH

# install dependencies
RUN pip install --upgrade pip
COPY requirements.txt ${PROJECT_ROOT}/requirements.txt
RUN pip install -r requirements.txt
# copy project
# COPY src ${PROJECT_ROOT}/src
RUN mkdir src