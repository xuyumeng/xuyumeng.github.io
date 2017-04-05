# 搜狗中文输入法无法输入中文
目前最好用的中文输入法就是搜狗输入法了——[http://pinyin.sogou.com/linux/](http://pinyin.sogou.com/linux/)

但是使用过程中会遇到无法输入中文的问题——可以呼出搜狗输入法界面, 但是候选词列表不显示中文，　如下图：

![sogou pinin no chinese display](img/ubuntu-daily-use/sogou-can-not--inpu-chinese.png)

 解决方法，　删除Sogou输入法的配置文件：

    cd ~/.config/
    find . -name "[Ss]ogou*" | xargs rm -rf
