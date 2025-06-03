# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx

COPY files/system /system_files
COPY files/scripts /build_files
COPY *.pub /keys

# Base Image
FROM quay.io/almalinuxorg/atomic-desktop-gnome:10@sha256:acd31f37ca86182a2facff11f2cd580b4545dad6b6b1a372ad210149e69e7d24

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
