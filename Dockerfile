# syntax=docker/dockerfile:1.20

# ------------------------------------------------------------------------------
# Talos system-extension image that ships a custom EDID binary
# ------------------------------------------------------------------------------
# The resulting image contains two things at the top level:
#  1. manifest.yaml  – metadata consumed by Talos
#  2. rootfs/        – files that will be overlayed on the Talos root filesystem
# ------------------------------------------------------------------------------

ARG TALOS_VERSION=1.10.6

FROM scratch

# Place EDID(s) inside rootfs so Talos overlays /usr/lib/firmware/edid
COPY edid/ /rootfs/usr/lib/firmware/edid/

# Ship the required manifest
COPY manifest.yaml /

# Image metadata (optional but nice-to-have)
LABEL org.opencontainers.image.title="talos-edid-extension" \
      org.opencontainers.image.description="Talos Linux system extension that ships custom EDID binary(ies)" \
      org.opencontainers.image.vendor="cmmmota" \
      org.opencontainers.image.version="${TALOS_VERSION}" 