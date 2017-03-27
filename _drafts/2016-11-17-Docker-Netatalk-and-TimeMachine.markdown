---
layout:     post
title:      "用 netatalk 让 Linux 成为你的 TimeMachine 备份服务器"
subtitle:   "随时随地，想备就备"
date:       2016-11-17 14:48 +08:00
author:     "Y.M. Xu"
header-img: "img/bg/post-2016-11-particle-collision.jpg"
catalog: true
tags:
    - macOS
    - TimeMachine
    - netatalk

---

``` bash
docker run --detach \
    --name "afp" \
    --hostname "timemachine" \
	--volume /var/timemachine/Share:/media/share \
	--volume /var/timemachine/TimeMachine:/media/timemachine \
    --net "host" \
    --env AFP_USER=$(name) \
    --env AFP_PASSWORD=$(password) \
    --publish 548:548 \
    cptactionhank/netatalk:latest
```