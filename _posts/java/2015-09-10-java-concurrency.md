---
layout:     post
title:      "java 并发"  
subtitle:   "java的并发中一些需要关注的点"
author:     Sun Jianjiao
header-img: "img/bg/default-bg.jpg"
catalog: true
tags:
    - java

---

# 1. 多线程同步—— join, CountDownLatch和CyclicBarrier

- join: 主线程等待子线程**结束**
- CountDownLatch: 一个线程等待多个线程的场景，保证1个线程和多个线程之间的同步。
- CyclicBarrier: 线程之间同步并通知

## 1.1 join

```Java
public class JoinExample {
    public static void main(String[] args) {
         Thread t1 = new Thread(() -> {
             System.out.println("I am in thread t1");
         });
         t1.start();

         try {
             t1.join();
         } catch (Exception InterruptedException) {
             Thread.currentThread().interrupt();
         }

         System.out.println("in main thread");
    }
}
```

输出:

```Text
I am in thread t1
in main thread
```

加了join后，**主线程会等待t1结束**，所以"in main thread" 永远在最后打印。

## 1.2 CountDownlantch

```Java
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

public class CountDownLatchExample {
    public static void main(String[] args) {
        Executor executor = Executors.newFixedThreadPool(2);

        for (int i = 0; i < 2; i++) {
            CountDownLatch latch = new CountDownLatch(2);

            executor.execute(() -> {
                System.out.println("Operation 1");

                latch.countDown();
            });

            executor.execute(() -> {
                System.out.println("Operation 2");

                latch.countDown();
            });

            try {
                latch.await();

                System.out.println("operation 1 and operation 2 finished.");
            } catch (InterruptedException ie) {

            }
        }
    }
}
```

```Text
Operation 1
Operation 2
operation 1 and operation 2 finished.
Operation 1
Operation 2
operation 1 and operation 2 finished.
```

通过循环初始化CountDownLatch, 使得主线程可以重复等待线程t1和t2的的操作执行完成。

## 1.3 CyclicBarrier

```Java
import java.util.concurrent.BrokenBarrierException;
import java.util.concurrent.CyclicBarrier;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

public class CyclicBarrierExample {
    public static void main(String[] args) {
        Executor executor = Executors.newFixedThreadPool(2);

        CyclicBarrier barrier = new CyclicBarrier(2, () -> {
            System.out.println("t1 and t2 execute finished");

//      打开注释，有10s睡眠的时候，第二次循环的执行，等待了10s，说明。只有回调执行完成后，才会重置计数器。
//            try {
//                Thread.sleep(10000);
//            } catch (InterruptedException ie) {
//
//            }
        });

        Thread t1 = new Thread(() -> {
           for (int i = 0; i < 2; i++) {
                System.out.println("thread t1");
                try {
                    barrier.await();
                } catch (BrokenBarrierException be) {

                } catch (InterruptedException ie) {

                }
           }
        });
        t1.start();

        Thread t2 = new Thread(() -> {
            for (int i = 0; i < 2; i++) {
                System.out.println("thread t2");
                try {
                    barrier.await();
                } catch (BrokenBarrierException be) {

                } catch (InterruptedException ie) {

                }
            }
        });
        t2.start();

        try {
            t1.join();
            t2.join();
        } catch (Exception ex) {

        }
    }
}
```

CyclicBarrier的**计数器是可以循环利用**的，并且具备自动重置的功能，一旦计数器减到0，会自动重置到你设置的初始值。

# 2. 线程池

创建一个线程，需要调用操作系统内核的API，操作系统要为线程分配一系列的资源，陈本很高，线程是一个重量级的对象，应该避免频繁创建和销毁。可以通过线程池避免。

## 2.1 如何实现一个线程池

线程池的设计和实现，目前普遍采用的是**生产者-消费者模式**。线程池的使用方是生产者，线程池本身是消费者。

```Java
import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

class ThreadPoolSimple {
    private int coreSize;
    private BlockingQueue<Runnable> blockingQueue;
    private List<Thread> threadList = new LinkedList<>();

    public ThreadPoolSimple(int coreSize, BlockingQueue<Runnable> blockingQueue) {
        this.coreSize = coreSize;
        this.blockingQueue = blockingQueue;

        for (int i = 0; i < coreSize; i++) {
            Thread thread = new Thread(() -> {
                while (true) {
                    try {
                        Runnable task = blockingQueue.take();
                        task.run();
                    } catch (InterruptedException ie) {

                    }
                }
            });
            thread.start();
            threadList.add(thread);
        }
    }

    public void execute(Runnable runnable) {
        blockingQueue.offer(runnable);
    }
}

public class ThreadPoolExample {
    static int i;

    public static void main(String[] args) {
        ThreadPoolSimple threadPoolSimple = new ThreadPoolSimple(2, new LinkedBlockingQueue<>(5));
        for (i = 0; i < 3; i++) {
            threadPoolSimple.execute(()-> {
                System.out.println("thread: " + Thread.currentThread().getName());
            });
        }
    }
}
```

线程池是一个生产者和消费者模型，创建线程池的时候，创建一个阻塞队列和初始化线程，线程里面执行从阻塞队列读取任务并执行。线程池的使用者，调用execute接口的时候，线程池只是将待执行的任务加入阻塞队列。

## 2.2 Java 线程池

```Java
ThreaddPoolExecutor(
    int corePoolSize,
    int maximumSize,
    long keepAliveTime,
    TimeUnit unit,
    Blocking<Runnable> workQueue,
    ThreadFactory threadFactory,
    RejectExecutionHandler handler)
```

- corePoolSize: 表示线程池保有的最小线程数。
- maxiumuPoolSize: 线程池创建的最大线程数。
- keepAliveTime & unit: 定义线程的空闲多久被回收
- workQueue: 阻塞队列
- threadFactory: 定义如何创建线程
- handler: 通过这个参数定义了工作队列满了的任务拒绝策略。

ThreadPoolHander定义了4种handler：

- CallerRunsPolicy: 提交任务的线程自己去执行任务。
- AbortPolicy： 默认的拒绝策略，抛出throws RejectedExecutionException。
- DiscardPolicy: 直接丢弃任务，没有任何异常抛出。
- DiscardOldestPolicy: 丢弃最老的任务，然后把最新的任务加入到工作队列。

1. 强烈建议**使用有界队列**，高负责情境下，无界队列很容易导致OOM。
2. 慎重使用**拒绝策略**，RejectedExectionException是一个运行时异常，很容易被忽略，所以最好定义自己的拒绝策略。
3. 如果execute提交的任务执行过程种异常，会导致执行任务的线程中止。捕获执行过程中的异常，按需处理。防止任务异常了，还没有收到任何通知。

```java
try {

} catch(RuntimeExecption re) {

} catch(Throwable t) {
}
```
