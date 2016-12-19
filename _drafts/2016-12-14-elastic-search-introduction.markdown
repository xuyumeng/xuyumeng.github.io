---
layout:     post
title:      "Elasticsearch 基本使用以及用 Docker 部署 "
subtitle:   "非常强大的全文搜索引擎以及方便的部署方式"
date:       2016-12-14 +08:00
author:     "Y.M. Xu"
header-img: "img/bg/post-2016-lake-wire.png"
catalog: true
tags:
    - Elasticsearch
    - Docker

---

```bash
$ curl -XDELETE 'http://localhost:9201/paper'
```

```bash
$ curl -XPUT http://localhost:9201/paper
```

```bash
$ curl -XPOST http://localhost:9201/paper/fulltext/_mapping -d'
{
    "fulltext": {
             "_all": {
            "analyzer": "ik",
            "search_analyzer": "ik",
            "term_vector": "no",
            "store": "false"
        },
        "properties": {
            "title": {
                "type": "string",
                "analyzer": "ik",
                "search_analyzer": "ik",
                "include_in_all": "true",
                "boost": 8
            },
            "abstract": {
                "type": "string",
                "analyzer": "ik",
                "search_analyzer": "ik",
                "include_in_all": "true",
                "boost": 8
            },
            "keywords": {
                "type": "string",
                "analyzer": "ik",
                "search_analyzer": "ik",
                "include_in_all": "true",
                "boost": 8
            },
            "author": {
                "type": "string",
                "analyzer": "ik",
                "search_analyzer": "ik",
                "include_in_all": "true",
                "boost": 8
            },
            "publish_date": {
                  "type": "date",
                  "format": "dateOptionalTime"
            }
        }
    }
}'
```