共享订阅(Shared Subscription)支持在多订阅者间采用分组负载平衡方式派发消息:

```
                            ---------
                            |       | --Msg1--> Subscriber1
Publisher--Msg1,Msg2,Msg3-->|  EMQ  | --Msg2--> Subscriber2
                            |       | --Msg3--> Subscriber3
                            ---------
```

http://emqtt.com/docs/v2/advanced.html#shared-subscription