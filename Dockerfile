FROM python:3.11-alpine

RUN apk add --no-cache nodejs npm ffmpeg git make g++

WORKDIR /hlsfy

ENV npm_config_python=/usr/bin/python3

RUN git clone https://github.com/Theryston/hlsfy.git .

RUN npm install
RUN npm run build
RUN npm prune --production
RUN rm -rf ./src

RUN chmod +x ./start.sh

WORKDIR /hlsfy-runpod

COPY . .

RUN pip install --no-cache-dir -r requirements.txt

RUN chmod +x entrypoint.sh

ENTRYPOINT ["/bin/sh", "entrypoint.sh"]