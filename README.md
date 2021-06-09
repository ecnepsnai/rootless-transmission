# rootless-transmission

This repository provides a OCI image for running the Transmission BitTorrent server and web client on a rootless
container. It is designed for use with podman, but may work with rootless Docker.

## What is "rootless"?

The term "rootless" means that the container does not run as the root user on your host. On most installations, Docker
runs as the root user and less privileged users can interact with the daemon locally. While Docker tries its best to
patch up security vulnerabilities it is still undoubted **not** a good idea to run things as root if you don't need to.

## What about the other images?

There are other transmission images out there, most notably [linuxserver/transmission](https://hub.docker.com/r/linuxserver/transmission),
which works well but doesn't work correctly when running rootless, because it assumes you're using Docker as root.

# How do I use this image?

It's simple!

```bash
mkdir Downloads
podman run \
    -d \
    --user root \
    -v $(readlink -f Downloads):/downloads:Z \
    -p 51413:51413 \
    -p 51413:51413/udp \
    -p 9091:9091 \
    --name transmission \
    ghcr.io/ecnepsnai/transmission:latest
```

This will start up transmission. You can access the web UI on port 9091. By default there is no username or password
required. More on that below.

*Note:* you may have noticed we specified `--user root` in the above command. This is a side effect of how rootless
podman works. It does not grant the container any extra privileges and it still is running as your user. For more
information, please see this wonderful [explanation and walk-through](https://www.tutorialworks.com/podman-rootless-volumes/)

## Volumes

|Volume|Description|Required|
|------|-----------|--------|
|`/downloads`|The directory where torrents will be downloaded to.|Yes.|
|`/config`|The directory where transmission stores all configuration and runtime data.|Only if you need to configure your container, or if you need your container to be portable.|
|`/watch`|A directory where transmission watches for any added *.torrent files. Files added here are automatically added to Transmission and deleted.|No.|

## Ports

|Port|Protocol|Description|Required|
|----|--------|-----------|--------|
|51413|TCP|The port used for the BitTorrent peer server.|Yes if you want to seed your torrents.|
|51413|UDP|The port used for the BitTorrent peer server.|Yes if you want to seed your torrents.|
|9091|TCP|The port used to access the web UI|Yes.|

## How do I configure it?

The web UI offers some configuration options, but for further configuration you will need to modify the settings JSON
file yourself.

Specify a directory for the `/config` volume and on startup the container will add the default `settings.json` file. If
you make changes to that file **while the container isn't running** those settings will be used the next time it starts.

For example:

```bash
mkdir Downloads Settings
podman run \
    -d \
    --user root \
    -v $(readlink -f Downloads):/downloads:Z \
    -v $(readlink -f Settings):/config:Z
    -p 51413:51413 \
    -p 51413:51413/udp \
    -p 9091:9091 \
    --name transmission \
    --rm \
    ghcr.io/ecnepsnai/transmission:latest
podman stop transmission
```

Now you can modify `Settings/settings.json`, then start the container again using the same run command and it will now
use your settings.

# How do I build this container?

This container is entirely self-contained, so building it only requires that you have `podman` installed.

```bash
podman build -t transmission --squash .
```

If you want to use a specific transmission version, you can specify that with a build argument:

```bash
podman build -t transmission --squash --build-arg TRANSMISSION_VERSION=2.94 .
```