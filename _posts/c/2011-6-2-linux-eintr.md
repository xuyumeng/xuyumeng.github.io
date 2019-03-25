---
layout:     post
title:      "EINTR的处理"
subtitle:   "Socket中数据发送和接收函数的封装"
author:     Sun Jianjiao
header-img: "img/bg/railway-station-1363771_1280.jpg"
catalog: true
tags:
    - Linux
    - c

---

man某个函数， 如果在ERRORS里面会有如下说明:
EINTR  The system call was interrupted by a signal that was caught; see signal(7).
说明次系统调用可能永远阻塞，永远无法返回，多数网络支持函数都属于这一类。如：若没有客户连接到服务器上，那么服务器的accept调用就会一直阻塞。

如果进程在一个慢系统调用中阻塞时，当捕获到某个信号且相应信号处理函数返回时，这个系统调用被中断，调用返回错误，设置errno为EINTR

怎么看哪些系统条用会产生EINTR错误呢？man 7 signal， 可以查看，哪些系统调用会产生 EINTR错误。 并不是所有在ERRORS里面有EINTER说明的都是会阻塞的函数， 但是要引起注意。


人为重启被中断的系统调用，所以经常看到如下对socket函数的封装

```c
/**
 * @brief Safe send when interrupted by signal
 *
 * @param sock  Socket fd
 * @param buf   Buffer for  message
 * @param len   Buffer length
 *
 * @return      0       Success
 *              !0      failed
 */
int send_safe(int sock, void *buf, size_t len)
{
        ssize_t nr;
        int ret = -1;

        do {    
                nr = send(sock, buf, len, 0); 
        } while ((-1 == nr) && (errno == EINTR));

        if (nr >= 0)
        {
                ret = 0;
        }

        return ret;
}
```

但是对EINTER的处理， 要遵循业务流程。 如当connect遇到EINTR错误时，不能向上面那样重新进入循环处理，原因是，connect的请求已经发送向对方，正在等待对方回应，这是如果重新调用connect，而对方已经接受了上次的connect请求，这一次的connect就会被拒绝，因此，需要使用select或poll调用来检查socket的状态，如果socket的状态就绪，则connect已经成功，否则，视错误原因，做对应的处理。
代码如下：

```c
static int check_conn_is_ok(int sock) 
{
    struct pollfd fd;
    int ret = 0;
    socklen_t len = 0;

    fd.fd = sock;
    fd.events = POLLOUT;

    while (poll(&fd, 1, -1)) 
    {
        if( errno != EINTR ){
            return -1;
        }
    }

    len = sizeof(ret);
    if (getsockopt(sock, SOL_SOCKET, SO_ERROR, &ret, &len)) 
    {
        perror("getsockopt");
        return -1;
    }

    if(ret != 0) {
        return -1;
    }

    return 0;
}

int connect_safe(int sockfd, const struct sockaddr *addr, socklen_t addrlen)
{
    int ret = 0;

    ret = connect(sockfd, addr, addrlen);
    if(ret) 
    {
        if(errno == EINTR) 
        {
            ret = check_conn_is_ok(sockfd); 
        }
    }

    return ret;
}
```