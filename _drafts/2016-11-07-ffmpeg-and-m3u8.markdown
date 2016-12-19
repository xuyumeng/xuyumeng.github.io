---
layout:     post
title:      "FFmpeg 定时下载转码 HLS 流媒体（m3u8）"
subtitle:   "Linux 下一行命令解决 HLS 下载与转码"
date:       2016-11-07 11:40 +08:00
author:     "Y.M. Xu"
header-img: "img/bg/railway-station-1363771_1280.jpg"
catalog: true
tags:
    - FFmpeg
    - HLS
    - 流媒体
    - Linux

---

有时候我们会遇到一些直播是用的 HLS（HTTP Live Streaming） 直播的，查看源代码的时候就能看到视频后缀是`m3u8`，这时如果你想要把某些时间段的视频保存下来的时候怎么办呢？录制卡录制或许是常见的方法，但是买卡又是一笔不小的费用；或者用软件屏幕录制，但是开着桌面太耗电，还可能会收到其他干扰（弹窗），这时最好的方法当然还是 Linux，通过 FFmpeg，一条命令即可录制并且转码，写几行脚本就能定时录制啦。

> 太长不看版: 请跳转至

## 什么是 HLS 和 m3u8



## 视频神器 FFmpeg

你可能接触 FFmpeg 最多的是在解码器方面，macOS 下最好播放器 mpv 就是用的 FFmpeg。

## 一行命令下载转码

```bash
ffmpeg -i http://url/cctv13.m3u8 -c copy -bsf:a aac_adtstoasc cctv13.mp4
```

## 写个脚本定时下载



