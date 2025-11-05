FROM docker:24.0-dind

RUN apk add --no-cache python3 py3-pip ca-certificates wget

WORKDIR /app

COPY requirements.txt .

ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_NO_CACHE_DIR=1
ENV PIP_BREAK_SYSTEM_PACKAGES=1
ENV DOCKER_TLS_CERTDIR=

RUN pip3 install -r requirements.txt

COPY . .

RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/bin/sh", "/app/entrypoint.sh"]