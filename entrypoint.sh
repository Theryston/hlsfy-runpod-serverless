#!/bin/sh
set -e

export DOCKER_TLS_CERTDIR=
/usr/local/bin/dockerd-entrypoint.sh >/var/log/dockerd.log 2>&1 &

echo "Starting Docker daemon..."
i=0
until docker info >/dev/null 2>&1; do
  i=$((i+1))
  if [ "$i" -gt 60 ]; then
    echo "Docker daemon failed to start after 60s" >&2
    cat /var/log/dockerd.log >&2 || true
    exit 1
  fi
  sleep 1
done

echo "Docker daemon is ready!"

# Ensure the image is present
docker pull theryston/hlsfy >/dev/null 2>&1 || docker pull theryston/hlsfy

# Determine exposed port from image metadata (fallback to 8080)
port=$(docker image inspect --format '{{range $k, $v := .Config.ExposedPorts}}{{println $k}}{{end}}' theryston/hlsfy | head -n1 | sed 's#/tcp##')
if [ -z "$port" ]; then
  port=8080
fi

cleanup() {
  if [ -n "$cid" ]; then
    docker stop "$cid" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

# Run the theryston/hlsfy container detached, publishing its port to localhost
cid=
cid=$(docker run -e IGNORE_CHECK_PROCESS=true -d -p 127.0.0.1:"$port":"$port" theryston/hlsfy)

export HLSFY_API_HOST="http://127.0.0.1:$port"
echo "HLSFY_API_HOST set to $HLSFY_API_HOST"

# Best-effort wait for API readiness
i=0
until wget -qO- "$HLSFY_API_HOST/health" >/dev/null 2>&1 || wget -qO- "$HLSFY_API_HOST" >/dev/null 2>&1; do
  i=$((i+1))
  if [ "$i" -ge 60 ]; then
    echo "theryston/hlsfy API not responding yet at $HLSFY_API_HOST; continuing" >&2
    break
  fi
  sleep 1
done

python3 -u rp_handler.py