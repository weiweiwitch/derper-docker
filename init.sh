#!/usr/bin/env bash

# run tailscaled
/usr/sbin/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/run/tailscale/tailscaled.sock --port=41641 --tun=userspace-networking -no-logs-no-support > /app/logs/tailscaled.log &
/usr/bin/tailscale up --auth-key $TAILSCALE_AUTH_KEY > /app/logs/tailscale.log &


# run derper
/app/derper --hostname=$DERP_DOMAIN \
    --certmode=$DERP_CERT_MODE \
    --certdir=$DERP_CERT_DIR \
    --a=$DERP_ADDR \
    --stun=$DERP_STUN  \
    --stun-port=${DERP_STUN_PORT} \
    --http-port=$DERP_HTTP_PORT \
    --verify-clients=$DERP_VERIFY_CLIENTS