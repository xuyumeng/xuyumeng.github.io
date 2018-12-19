1. 

```
func mirrordQuery() string{
    responses := make(chan string)

    go func() {
        responses := make <- request("mirror1.eclipse.de")
    }()

    go func() {
        responses := make <- request("mirror1.eclipse.us")
    }()

    
    go func() {
        responses := make <- request("mirror1.eclipse.cn")
    }()

    return <-responses
}

func request(hostname string) (response string) {
    /* ... */
}

```

这个程序的作用是什么？
有问题吗？

正确答案：
```
func mirrordQuery() string{
    responses := make(chan string, 3)

    go func() {
        responses := make <- request("mirror1.eclipse.de")
    }()

    go func() {
        responses := make <- request("mirror1.eclipse.us")
    }()

    
    go func() {
        responses := make <- request("mirror1.eclipse.cn")
    }()

    return <-responses
}

func request(hostname string) (response string) {
    /* ... */
}

```

返回最快的请求。

返回慢的goroutine被卡住，造成goroutine泄露