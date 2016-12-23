---
layout:     post
title:      "在 Terminal prompt 中显示 git branch 的名字"
subtitle:   "虽然很简单但是很方便的功能"
date:       2016-12-20 11:09:00 +08:00
author:     "Y.M. Xu"
header-img: "img/bg/post-2016-lake-wire.png"
catalog: true
tags:
    - Terminal
    - Git

---

刚才在看别人发的终端录像的时候看到在 Terminal prompt 中显示了 branch 的名字，然后觉得很方便，工程多了有时候会忘记有没有把项目添加到 git 里，当前 branch 是什么，总是要 `git branch` 或 `git status` 来查看，如果能自动显示在 Terminal prompt 中就会很方便，所以就 google 了一下相关的东西。

[ADD GIT BRANCH NAME TO TERMINAL PROMPT (MAC)](http://mfitzp.io/article/add-git-branch-name-to-terminal-prompt-mac/)

```bash
# Git branch in prompt.

parse_git_branch() {

    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'

}

export PS1="\u@\h \W\[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "
```