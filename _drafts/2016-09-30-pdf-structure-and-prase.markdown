---
layout:     post
title:      "PDF 文件结构及其解析"
subtitle:   ""
date:       2016-09-30 11:40 +08:00
author:     "Y.M. Xu"
header-img: "img/bg/railway-station-1363771_1280.jpg"
catalog: true
tags:
    - PDF

---

因为有时候需要用到 PDF 中的数据，复制又非常麻烦，特别是表格，复制出来无法保持原有结构，需要一个单元格一个单元格的复制，非常低效，所以希望能写出提取 PDF 文件中数据的方法。想解析就要先研究一下 PDF 文件的结构，并且要把文件解析成文本才能进一步处理。

![PDF_STRUCTURE](/img/post/2016-09-30/pdf_struture.png)