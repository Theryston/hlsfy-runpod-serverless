#!/bin/sh
set -e

# Start Docker daemon (from docker:dind)
/usr/local/bin/dockerd-entrypoint.sh >/var/log/dockerd.log 2>&1 &

# Wait for Docker to be ready
tries=0
until docker info >/dev/null 2>&1; do
  tries=$((tries+1))
  if [ "$tries" -ge 60 ]; then
    echo "Docker daemon not ready after 60s" >&2
    exit 1
  fi
  sleep 1
done

# Ensure the image is present
docker pull theryston/hlsfy >/dev/null 2>&1 || docker pull theryston/hlsfy

# Determine exposed port from image metadata (fallback to 8080)
port=$(docker image inspect --format '{{range $k, $v := .Config.ExposedPorts}}{{println $k}}{{end}}' theryston/hlsfy | head -n1 | sed 's#/tcp##')
if [ -z "$port" ]; then
  port=8080
fi

# Run the theryston/hlsfy container detached
cid=$(docker run -e IGNORE_CHECK_PROCESS=true -d theryston/hlsfy)

# Resolve container IP inside the DinD network namespace
ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$cid")
if [ -z "$ip" ]; then
  echo "Failed to resolve theryston/hlsfy container IP" >&2
  exit 1
fi

export HLSFY_API_HOST="http://$ip:$port"
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

exec python3 -u rp_handler.py

docker stop $cid
docker rm $cid

echo "Container stopped and removed"