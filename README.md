# My Atomic AlmaLinux Respin

Welcome to your brand-new Atomic AlmaLinux Respin!

## Initial Setup

### Set basic configuration

In the ["Build image"](.github/workflows/build.yml) and ["Build ISOs"](.github/workflows/build-iso.yml) jobs, you'll
find a `set-env` job where you can configure several things:

- `REGISTRY`: the registry to push your image to
- `REGISTRY_USER`: your username for this registry
- `IMAGE_PATH`: the path to your image
- `IMAGE_NAME`: your image's name
- `PLATFORMS`: a comma-separated list of platforms for which to build your image, like `"amd64,arm64"`

If your registry is not Github (ie. `ghcr.io`) or you need a specific token to authenticate
to your registry, search those two jobs for the line `REGISTRY_TOKEN: ${{ secrets.GITHUB_TOKEN }}`
and replace the token for the appropriate secret.

### Pick a base desktop image

By default, this template configures the base image `quay.io/almalinuxorg/atomic-desktop-gnome:10`,
which is [maintained](https://github.com/AlmaLinux/atomic-desktop) by the [AlmaLinux Atomic SIG](https://wiki.almalinux.org/sigs/Atomic.html).
If you're not a fan of Gnome, you could also pick our KDE image (`quay.io/almalinuxorg/atomic-desktop-kde:10`).

If you'd like to switch images, change the `FROM` line in the [Dockerfile](Dockerfile).
If you switch to an entirely new key, note that you will also have to download a new Cosign public
key for this image and specify it's name in the `upstream-public-key` configuration
parameter of `/.github/workflows/build.yml`, or remove that parameter altogether to
disable key verification.

### Setting up Cosign (Optional)

If you'd like to sign your images using Cosign, here's what you need to do:

1. Generate a cosign key:
    `podman run --rm -it -v /tmp:/cosign-keys bitnami/cosign generate-key-pair`
    Hit enter when asked for a private key password (that is, don't set a password). Once complete, you'll find the new key in `/tmp/cosign.{key,pub}` on your machine.

2. Add `cosign.pub` to this repository as `/cosign.pub`, commit and push. Feel free to publish this file in other places too, it will be needed by everyone to verify the signature of the published images.

3. In the github repo settings, go to "Secrets and variables" in the "Security" subsection and click on "Actions". Create a new Repository secret called `SIGNING_SECRET` and paste the contents of `cosign.key`. Save `cosign.key` in a secure location and delete it from your /tmp directory.

## Customizing your respin

Now that you're all set up, it's time for the fun part!

### Adding files

Any files you place in [`/files/system/`](files/system/) will be added to your image as is,
preserving directory structure and file permissions. This is a simple mechanism for adding
themes, backgrounds, etc.

### Executing commands

In [`/files/scripts/`](files/scripts/), you'll find a series of scripts that will be run
during image creation. The `build.sh` script will first copy all the files from `/files/system/`
into the image, then run the scripts in order, and finally run `cleanup.sh`. You can start by modifying [`10-base.sh`](files/scripts/10-base.sh)
to suit your needs, and add more scripts as needed (always with the naming scheme `XX-whatever.sh`, where XX is a number).

Do not modify `build.sh`, `cleanup.sh`, `90-signing.sh` or `91-image-info.sh` unless you
understand what you're doing, those scripts should not need any customization under normal circumstances.

### Build your new image

Once you've added your files and scripts, commit your changes to let the CI build a new
image for you. You can also run `make image` on your machine to build the image locally.
