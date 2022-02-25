FROM python:3.8-slim

# to install python package psycopg2 (for postgres)
RUN apt-get update
RUN apt-get install -y gcc

# add user (change to whatever you want)
# prevents running sudo commands
RUN useradd -r -s /bin/bash kennethcaple

# set current env
ENV HOME /app
WORKDIR /app
ENV PATH="/app/.local/bin:${PATH}"

RUN chown -R kennethcaple:kennethcaple /app
USER kennethcaple


COPY . .
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  locales
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  
RUN export LC_ALL=C.UTF-8 && export LANG=C.UTF-8h
RUN bash miniconda.sh -b -u -p ~/miniconda3
RUN ~/miniconda3/bin/conda init bash
RUN ~/miniconda3/bin/conda init zsh
RUN bash
RUN export LC_ALL=C.UTF-8 && export LANG=C.UTF-8
RUN ~/miniconda3/bin/conda install python=3.6
RUN ~/miniconda3/bin/pip install ffmpeg tensorflow==2.5.0
RUN ~/miniconda3/bin/conda install -c conda-forge libsndfile
RUN ~/miniconda3/bin/pip install spleeter
RUN apt-get install ffmpeg -y

# set app config option
ENV FLASK_ENV=production

# set argument vars in docker-run command
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_DEFAULT_REGION
# flask form key
ARG FLASK_SECRET_KEY

ENV AWS_ACCESS_KEY_ID $AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY $AWS_SECRET_ACCESS_KEY
ENV AWS_DEFAULT_REGION $AWS_DEFAULT_REGION
ENV FLASK_SECRET_KEY $FLASK_SECRET_KEY

# Avoid cache purge by adding requirements first
ADD ./requirements.txt ./requirements.txt

RUN pip install --no-cache-dir -r ./requirements.txt --user

# Add the rest of the files
COPY . /app
WORKDIR /app

# start web server
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app", "--workers=5"]
