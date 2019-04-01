---
layout:     post
title:      "网络IO实现方式"  
subtitle:   "BIO, NIO, AIO"
author:     Sun Jianjiao
header-style: text
catalog: true
tags:

    - java

---

# 1. BIO

BIO即Blocking IO, 采用阻塞的方式实现。也就是一个Socket套接字需要使用一个线程来进行处理。发生建立连接，读数据，写数据的操作时，都可能会阻塞。这个模式的好处是简单，但是带来的主要问题是一个线程只能处理一个socket， 如果是Server端，支持并发的连接时，就需要更多的线程来完成这个工作。一般情况下，Server端使用线程池减轻线程创建和销毁的开销。

![bio](/img/post/java/nio-bio-aio/bio.png)

Client端的代码

```Java
package BlockIO.BlockIOClient;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;

class BlockIOClient {
    private static Integer PORT = 18000;
    private static String IP_ADDRESS = "127.0.0.1";

    public void clientRequest() {
        Socket socket = null;
        BufferedReader reader = null;
        PrintWriter writer = null;
        try {
            socket = new Socket(IP_ADDRESS, PORT); // 双方通过输入和输出流进行同步阻塞式通信
            reader = new BufferedReader(new InputStreamReader(socket.getInputStream())); // 获取返回内容
            writer = new PrintWriter(socket.getOutputStream(), true);

            for (int i = 0; i < 10; i++) {
                writer.println(i);
                System.out.println(" 客户端打印返回数据 : " + reader.readLine());
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (null != reader) {
                    reader.close();
                }

                if (null != writer) {
                    writer.close();
                }

                if (null != socket) {
                    socket.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}

public class Main {
    public static void main(String[] args) {
        BlockIOClient blockIOClient = new BlockIOClient();
        blockIOClient.clientRequest();
    }
}
```

Server端的代码:

```Java
package BlockIO;

import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

class BlockIO {
    private final Integer PORT = 18000;

    private void run(Socket socket) {
        InputStreamReader inputStreamReader = null;
        PrintWriter outputWriter = null;
        try {
            inputStreamReader = new InputStreamReader(socket.getInputStream());
            BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
            outputWriter = new PrintWriter(socket.getOutputStream(), true);
            String line;
            while ((line = bufferedReader.readLine()) != null) {
                System.out.println("Receive: " + line);
                outputWriter.println(Byte.valueOf(line));
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            try {
                if (null != inputStreamReader) {
                    inputStreamReader.close();
                }

                if (null != outputWriter) {
                    outputWriter.close();
                }

                if (null != socket) {
                    socket.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }


    public void server() {
        ThreadPoolExecutor executor = new ThreadPoolExecutor(5, 10, 200, TimeUnit.MILLISECONDS,
                new ArrayBlockingQueue<>(5));

        ServerSocket echoServer = null;
        Socket clientSocket;
        try {
            echoServer = new ServerSocket(PORT);
        } catch (IOException e) {
            System.out.println(e);
        }
        while (true) {
            try {
                clientSocket = echoServer.accept();
                System.out.println(clientSocket.getRemoteSocketAddress() + " connect!");

                Socket finalClientSocket = clientSocket;
                executor.execute(() -> {
                    run(finalClientSocket);
                });
            } catch (IOException e) {
                System.out.println(e);
            }
        }
    }
}

public class Main {

    public static void main(String[] args) {
        new BlockIO().server();
    }
}

```