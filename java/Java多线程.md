# Java多线程
## 线程锁

### 范例一
```
public static volatile User user;

public static User getUser() {

        if (user == null) {
            synchronized (User.class) {
                if (user == null) {
                    user = new User();
                    return user;
                }
            }
        }
        return user;
    }
```
### 范例二
```
 public static int init_num = 0;
 private static ReentrantLock reentrantLock = new ReentrantLock();

 public static void upNum2() {

        reentrantLock.lock();
        try {
            int i = ++init_num;
            System.out.println(i);
        }
        finally {
            reentrantLock.unlock();
        }


    }
```

## 线程创建方式


### 1. newFixedThreadPool(int nThreads)
创建一个固定长度的线程池，每当提交一个任务就创建一个线程，直到达到线程池的最大数量，这时线程规模将不再变化，当线程发生未预期的错误而结束时，线程池会补充一个新的线程

### 2. newCachedThreadPool()
创建一个可缓存的线程池，如果线程池的规模超过了处理需求，将自动回收空闲线程，而当需求增加时，则可以自动添加新线程，线程池的规模不存在任何限制

### 3. newSingleThreadExecutor()
这是一个单线程的Executor，它创建单个工作线程来执行任务，如果这个线程异常结束，会创建一个新的来替代它；它的特点是能确保依照任务在队列中的顺序来串行执行

### 4. newScheduledThreadPool(int corePoolSize)
创建了一个固定长度的线程池，而且以延迟或定时的方式来执行任务，类似于Timer。



## Semaphore 使用
```
Semaphore semaphore = new Semaphore(3); //机器数目
        for (var i = 0; i < 9; i++) {

            CompletableFuture.runAsync(() -> {

                System.out.println("申请获取资源");
                try {
                    semaphore.acquire();
                    System.out.println("获取到资源");
                    TimeUnit.SECONDS.sleep(10);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                semaphore.release();
                System.out.println("释放资源");
            }, Executors.newCachedThreadPool());


        }

        while (true) {

        }
```

## CountDownLatch 使用
```
 CountDownLatch countDownLatch=new CountDownLatch(2);
        CompletableFuture.runAsync(()->{
            System.out.println("onw finish");
            countDownLatch.countDown();
        });
        CompletableFuture.runAsync(()->{
            System.out.println("two finish");
            countDownLatch.countDown();
        });
        try {
            countDownLatch.await();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("all finish");
```

## CyclicBarrier使用
```
 
        CyclicBarrier barrier = new CyclicBarrier(2);
        CompletableFuture.runAsync(() -> {
            System.out.println("就绪1");
            try {
                barrier.await(2, TimeUnit.SECONDS);
            } catch (InterruptedException e) {
                e.printStackTrace();
            } catch (BrokenBarrierException e) {
                e.printStackTrace();
            } catch (TimeoutException e) {
                System.out.println("错误：等不了了自己走了");
            }
            System.out.println("出发1");

        });
        CompletableFuture.runAsync(() -> {

            try {
                Thread.sleep(3000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

            System.out.println("就绪2");
            try {
                barrier.await();
            } catch (InterruptedException e) {
                e.printStackTrace();
            } catch (BrokenBarrierException e) {
                System.out.println("错误：有人不等先走了,屏障被打破了");
            }
            System.out.println("出发2");
        });


        while (true) {

        }
    
```

## Callable+Future

#### 使用Future
```
ExecutorService executor = Executors.newCachedThreadPool();

        /*定义任务，实现Callable接口*/
        Callable<Integer> callable = ()->{
            System.out.println("子线程"+Thread.currentThread().getName()+"在进行计算");

            int sum = 0;
            for (int i = 0; i < 100; i++)
                sum += i;
            return sum;
        };

        Future<Integer> r3 = executor.submit(callable);//添加任务
        executor.shutdown();//不再接受任务
        try {
            Integer integer = r3.get();//会阻塞
            System.out.println("运行结果"+integer);
        } catch (ExecutionException e) {
            e.printStackTrace();
        }
        System.out.println("所有任务执行完毕");
```

#### 使用FutureTask
```
 FutureTask<Integer> futureTask = new FutureTask<Integer>(() -> {
            TimeUnit.SECONDS.sleep(2);
            return 1;
        });
        new Thread(futureTask).start();
        try {
            Integer integer = futureTask.get();
            System.out.println("响应："+integer);
        } catch (InterruptedException e) {
            e.printStackTrace();
        } catch (ExecutionException e) {
            e.printStackTrace();
        }
```




## Runnable接口方式
```
Runnable runnable=()->{
            if (TreadTest.num>0){
                TreadTest.num--;
            }
        };
        Thread thread=new Thread(runnable);
        thread.start();
```

## 继承Thread类方式
```
public class TreadTest extends Thread{
@Override
    public void run() {
        if (TreadTest.num>0){
            TreadTest.num--;
        }
    }
}
```
