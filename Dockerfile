# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx

COPY files/system /system_files
COPY files/scripts /build_files
COPY cosign.pub /cosign.pub

# Base Image
FROM  quay.io/almalinuxorg/almalinux-desktop-bootc:latest@sha256:73f9597797e310ec2920e1f87ad6b53c4e3e4232990f5dbdb4b09587ecaf197d

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
