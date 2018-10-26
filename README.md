dockerfile for building language examples in OpenWrt

## build dockerfile

```
$ docker build -t sartura:languages -f Dockerfile .
```

Docker build will compile an image based on the rp3_config diffconfig.
The OpenWrt repository is located at /home/openwrt/openwrt.

## run dockerfile

```
$ docker run --rm openwrt:languages bash
$ cd openwrt
```
