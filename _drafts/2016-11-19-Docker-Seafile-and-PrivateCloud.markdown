---
layout:     post
title:      "Seafile 基本配置以及用 Docker 部署 "
subtitle:   "妈妈再也不用担心某云倒闭啦"
date:       2016-11-19 +08:00
author:     "Y.M. Xu"
header-img: "img/bg/post-2016-lake-wire.png"
catalog: true
tags:
    - Seafile
    - Docker

---

```bash
docker run -t -i \
  -p 10001:10001 \
  -p 12001:12001 \
  -p 8000:8000 \
  -p 8080:8080 \
  -p 8082:8082 \
  -v /var/cloud/seafile:/opt/seafile \
  jenserat/seafile -- /bin/bash
```

```bash
docker run -d \
  --name seafile \
  -p 10001:10001 \
  -p 12001:12001 \
  -p 8000:8000 \
  -p 8080:8080 \
  -p 8082:8082 \
  -v /var/cloud/seafile:/opt/seafile \
  -e autostart=true \
  jenserat/seafile
```