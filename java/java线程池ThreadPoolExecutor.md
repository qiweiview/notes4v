# java线程池ThreadPoolExecutor

## 钩子方法(需要子类重写)
```
 @Override
    protected void afterExecute(Runnable r, Throwable t) {
        super.afterExecute(r, t);
        System.out.println("执行结束");
    }

    @Override
    protected void beforeExecute(Thread t, Runnable r) {
        System.out.println("执行开始");
        super.beforeExecute(t, r);
    }
```

## 当工作队列满并且工作线程数到达最大线程数，任务会被拒绝
* 拒绝时调用RejectedExecutionHandler的方法
```
        ThreadPoolExecutor threadPoolExecutor = new ThreadPoolExecutor(1, 1,
                0L, TimeUnit.MILLISECONDS,
                new MyLin<Runnable>(1));

        threadPoolExecutor.setRejectedExecutionHandler((r,e)->{
            System.out.println("拒绝任务："+r);
        });
        Runnable runnable = () -> {
            Thread thread = Thread.currentThread();
            synchronized (thread) {
                try {
                    thread.wait();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }

        };

        threadPoolExecutor.execute(runnable);
        threadPoolExecutor.execute(runnable);
        threadPoolExecutor.execute(runnable);
```
