FROM golang:latest AS builder
WORKDIR /app

# https://tailscale.com/kb/1118/custom-derp-servers/
# version: https://pkg.go.dev/tailscale.com/cmd/derper
RUN go install tailscale.com/cmd/derper@v1.66.4

FROM ubuntu:22.04
WORKDIR /app

LABEL app=tailscale-derper

ARG DEBIAN_FRONTEND=noninteractive

COPY init.sh ./init.sh

RUN apt update && \
    apt install -y --no-install-recommends apt-utils && \
    apt install -y ca-certificates curl && \
    mkdir /app/certs && \
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null && \
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list && \
    apt update && \
    apt install -y tailscale && \
    chmod +x ./init.sh

ENV DERP_DOMAIN your-hostname.com
ENV DERP_CERT_MODE letsencrypt
ENV DERP_CERT_DIR /app/certs
ENV DERP_ADDR :443
ENV DERP_STUN true
ENV DERP_STUN_PORT 3478
ENV DERP_HTTP_PORT 80
ENV DERP_VERIFY_CLIENTS false
ENV TAILSCALE_AUTH_KEY 111

COPY --from=builder /go/bin/derper .

ENTRYPOINT ./init.sh

