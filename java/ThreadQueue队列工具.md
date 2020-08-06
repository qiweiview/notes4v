# ThreadQueue队列工具


* 任务由连接池执行，连接池会维护固定数量的工作线程
* 设置连接池的线程工厂，在异常时归还未完成任务
* 工具内部线程worker仅用于监听阻塞队列，把阻塞队列中的任务拿出交由线程池执行


```


import java.util.UUID;
import java.util.concurrent.*;

/**
 * thread safe
 */
public class ThreadQueue {
    private String name;//队列名
    private LinkedBlockingQueue<InnerTask> linkedBlockingQueue = new LinkedBlockingQueue();//任务队列
    private LinkedBlockingQueue<InnerTask> deathQueue = new LinkedBlockingQueue();//死信队列
    private ExecutorService executorService;//线程池
    private final ThreadLocal<InnerTask> threadLocal = new ThreadLocal();//线程变量
    private Thread worker;//启动线程
    private ThreadQueue nextLevelThreadQueue;//下一级队列
    private ThreadQueue successLogThreadQueue;//日志队列
    private volatile boolean init = false;//初始化标志


    public ThreadQueue() {
    }


    public ThreadQueue(String name) {
        this.name = name;
    }


    public ThreadQueue getNextLevelThreadQueue() {
        return nextLevelThreadQueue;
    }

    public void setNextLevelThreadQueue(ThreadQueue nextLevelThreadQueue) {
        this.nextLevelThreadQueue = nextLevelThreadQueue;
    }

    public String getName() {
        return name;
    }

    /**
     * 初始化组件
     */
    private void start() {
        if (executorService == null) {
            initDefaultPool();
        }

        worker = new Thread(() -> {
            while (true) {
                try {
                    InnerTask take = linkedBlockingQueue.take();
                    take.register(this);
                    executorService.execute(take);
                    if (successLogThreadQueue!=null){
                            successLogThreadQueue.submit(take);
                        }
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }

            }
        });
        worker.start();


    }

    /**
     * 提交任务
     *
     * @param innerTask
     */
    public void submit(InnerTask innerTask) {
        if (!init) {
            synchronized (this) {
                if (!init) {
                    start();
                    init = true;
                }
            }

        }
        linkedBlockingQueue.add(innerTask);
    }

    /**
     * 死信队列长度
     *
     * @return
     */
    public Integer getFailNumber() {
        return deathQueue.size();
    }

    /**
     * 初始化默认线程池
     */
    private void initDefaultPool() {
        executorService = Executors.newFixedThreadPool(1, new InnerThreadFactory());
    }


    /**
     * 线程工厂
     */
    private class InnerThreadFactory implements ThreadFactory {


        @Override
        public Thread newThread(Runnable r) {
            Thread thread = new Thread(r);
            Thread.UncaughtExceptionHandler uncaughtExceptionHandler = new Thread.UncaughtExceptionHandler() {
                @Override
                public void uncaughtException(Thread t, Throwable e) {
                    try {
                        TimeUnit.SECONDS.sleep(1);
                    } catch (InterruptedException interruptedException) {
                        interruptedException.printStackTrace();
                    }
                    InnerTask innerTask = threadLocal.get();
                    if (innerTask.runBreak()) {
                        if (nextLevelThreadQueue != null) {
                            innerTask.clearRecord();
                            nextLevelThreadQueue.submit(innerTask);
                        } else {
                            deathQueue.add(innerTask);
                        }

                    } else {
                        linkedBlockingQueue.add(innerTask);
                    }
                }
            };
            thread.setUncaughtExceptionHandler(uncaughtExceptionHandler);
            return thread;
        }
    }

    /**
     * 队列任务
     */
    public static abstract class InnerTask implements Runnable {

        public ThreadQueue threadQueue;
        private Integer failTime = 0;


        private void register(ThreadQueue threadQueue) {
            this.threadQueue = threadQueue;
        }

        public String getUniqueKey() {
            return UUID.randomUUID().toString();
        }

        public void clearRecord() {
            this.failTime = 0;
        }

        public boolean runBreak() {
            failTime++;
            return failTime >= configTakRunFailTimes();
        }

        public abstract void runDetail();

        public abstract Integer configTakRunFailTimes();

        @Override
        public void run() {
            threadQueue.threadLocal.set(this);
            runDetail();
        }
    }
}

```


### jdk 7 support
```

import java.util.UUID;
import java.util.concurrent.*;

/**
 * thread safe
 */
public class ThreadQueue {
    private String name;//队列名
    private LinkedBlockingQueue<InnerTask> linkedBlockingQueue = new LinkedBlockingQueue();//任务队列
    private LinkedBlockingQueue<InnerTask> deathQueue = new LinkedBlockingQueue();//死信队列
    private ExecutorService executorService;//线程池
    private final ThreadLocal<InnerTask> threadLocal = new ThreadLocal();//线程变量
    private Thread worker;//启动线程
    private ThreadQueue nextLevelThreadQueue;//下一级失败队列
    private ThreadQueue successLogThreadQueue;//日志队列
    private volatile boolean init = false;//初始化标志


    public ThreadQueue() {
    }


    public ThreadQueue(String name) {
        this.name = name;
    }


    public ThreadQueue getNextLevelThreadQueue() {
        return nextLevelThreadQueue;
    }

    public void setNextLevelThreadQueue(ThreadQueue nextLevelThreadQueue) {
        this.nextLevelThreadQueue = nextLevelThreadQueue;
    }

    public String getName() {
        return name;
    }

    /**
     * 初始化组件
     */
    private void start() {
        if (executorService == null) {
            initDefaultPool();
        }

        final ThreadQueue threadQueue = this;

        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                while (true) {
                    try {
                        InnerTask take = linkedBlockingQueue.take();
                        take.register(threadQueue);
                        executorService.execute(take);
                        if (successLogThreadQueue!=null){
                            successLogThreadQueue.submit(take);
                        }
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }

                }

            }
        };
        worker = new Thread(runnable);
        worker.start();


    }

    /**
     * 提交任务
     *
     * @param innerTask
     */
    public void submit(InnerTask innerTask) {
        if (!init) {
            synchronized (this) {
                if (!init) {
                    start();
                    init = true;
                }
            }

        }
        linkedBlockingQueue.add(innerTask);
    }

    /**
     * 死信队列长度
     *
     * @return
     */
    public Integer getFailNumber() {
        return deathQueue.size();
    }

    /**
     * 初始化默认线程池
     */
    private void initDefaultPool() {
        executorService = Executors.newFixedThreadPool(1, new InnerThreadFactory());
    }




    /**
     * 线程工厂
     */
    private class InnerThreadFactory implements ThreadFactory {


        @Override
        public Thread newThread(Runnable r) {
            Thread thread = new Thread(r);
            Thread.UncaughtExceptionHandler uncaughtExceptionHandler = new Thread.UncaughtExceptionHandler() {
                @Override
                public void uncaughtException(Thread t, Throwable e) {
                    e.printStackTrace();
                    try {
                        TimeUnit.SECONDS.sleep(1);
                    } catch (InterruptedException interruptedException) {
                        interruptedException.printStackTrace();
                    }
                    InnerTask innerTask = threadLocal.get();
                    if (innerTask.runBreak()) {
                        if (nextLevelThreadQueue != null) {
                            innerTask.clearRecord();
                            nextLevelThreadQueue.submit(innerTask);
                        } else {
                            deathQueue.add(innerTask);
                        }

                    } else {
                        linkedBlockingQueue.add(innerTask);
                    }
                }
            };
            thread.setUncaughtExceptionHandler(uncaughtExceptionHandler);
            return thread;
        }
    }

    /**
     * 队列任务
     */
    public static abstract class InnerTask implements Runnable {


        public ThreadQueue threadQueue;
        private Integer failTime = 0;
        


        private void register(ThreadQueue threadQueue) {
            this.threadQueue = threadQueue;
        }

        public String getUniqueKey() {
            return UUID.randomUUID().toString();
        }

        public void clearRecord() {
            this.failTime = 0;
        }

        public boolean runBreak() {
            failTime++;
            return failTime >= configTakRunFailTimes();
        }

        public abstract void runDetail();

        public abstract Integer configTakRunFailTimes();

        @Override
        public void run() {
            threadQueue.threadLocal.set(this);
            runDetail();
        }
    }
}

```
