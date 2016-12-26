---
layout:     post
title:      "Plex 基本配置以及用 Docker 部署 "
subtitle:   ""
date:       2016-11-20 +08:00
author:     "Y.M. Xu"
header-img: "img/bg/post-2016-lake-wire.png"
catalog: true
tags:
    - Seafile
    - Docker

---
```bash
docker create \
--name=plex \
--net=host \
-e VERSION=latest \
-e PUID=985 -e PGID=979 \
-e TZ=Asia/Shanghai \
-v /var/cloud/plex/config:/config \
-v /var/cloud/plex/tvshows:/data/tvshows \
-v /var/cloud/plex/movies:/data/movies \
-v /var/cloud/plex/transcode:/transcode \
linuxserver/plex
```