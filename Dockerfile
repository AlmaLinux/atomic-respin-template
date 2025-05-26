# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx

COPY files/system /system_files
COPY files/scripts /build_files
COPY *.pub /keys

# Base Image
FROM quay.io/almalinuxorg/almalinux-desktop-bootc:latest@sha256:9995bfbce14d03b5bfacd58eeeea8bbef353a84faac8e06d35ff3f5b382a4bdf

ARG IMAGE_NAME
ARG IMAGE_REGISTRY

RUN --mount=type=tmpfs,dst=/opt \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build_files/build.sh && \
    ostree container commit

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
