#!/bin/sh

( cd /hlsfy && IGNORE_CHECK_PROCESS="true" ./start.sh ) &

HLSFY_API_HOST="http://localhost:3000" python3 -u rp_handler.py