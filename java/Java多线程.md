# Java多线程
## 守护线程
* main线程不是守护线程
* 虚拟机里存在守护线程则虚拟机不会关闭
* 线程开启后无法设置daemon值
```
        Thread thread = new Thread();

        thread.setDaemon(true);

        thread.start();
```

## ExecutorService 异常
* execute出现异常时，会把异常跑出来
* submit出现异常时，会把异常存储，并把状态值改为异常，在Future调用get()时候检验
```

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

public class ExecutorsTest {
    public static void main(String[] args) throws Exception {
        ExecutorService executorService = Executors.newFixedThreadPool(2);

        Future<Object> submit = executorService.submit(() -> {
            System.out.println("submit");
            throw new RuntimeException("submit exception");
        });
        Object o = submit.get();
        System.out.println(o);
        
        executorService.execute(()->{
            System.out.println("execute");
            throw new RuntimeException("execute exception");
        });
    }
}

```

## 循环定时任务
```
package thread;

import java.util.concurrent.*;

public class ThreadPool {
    public static int i = 0;
    public static ScheduledExecutorService scheduledExecutorService = Executors.newSingleThreadScheduledExecutor(new MyThreadFactory());
    public static Runnable runnable = () -> {

        i++;
        if (i == 5) {
            i = 0;
            throw new NullPointerException();
        } else {
            System.out.println(i);
        }
    };

    public static void main(String[] args) {

        int i = 0;
        while (true) {
            startOne();
            i++;
            if (i == 3) {
                scheduledExecutorService.shutdown();
            }

        }


    }

    public static void startOne() {
        ScheduledFuture<?> scheduledFuture = scheduledExecutorService.scheduleWithFixedDelay(runnable, 1, 1, TimeUnit.SECONDS);
        try {
            Object o = scheduledFuture.get();
        } catch (Exception e) {
            System.out.println("抛出：" + e);
        }
    }


}

```

## Join的使用
* A,B两线程运行，B线程中调用A.join()，则B线程会在A线程执行完后执行
```

        Runnable runnable=()->{
            int i=0;
            while (i<5){
                try {
                    TimeUnit.SECONDS.sleep(1);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                System.out.println(i);
                i++;
            }
        };
        Runnable runnable2=()->{
            System.out.println(2);
        };
        Runnable runnable3=()->{
            System.out.println(3);
        };
        Thread thread = new Thread(runnable);
        thread.start();
        thread.join();


        new Thread(runnable2).start();//等待第一个线程
        new Thread(runnable3).start();//等待第一个线程


```


## 用户线程和守护线程
* JVM会在只剩下守护线程的时候关闭（守护线程不会阻止jvm关闭，普通线程会），如果不存在守护线程，只有用户线程未完成，那么就会一直阻塞
```
   public static void main(String[] args) {
        Thread t = new Thread(() -> {
            Thread thread = Thread.currentThread();
            synchronized (thread){
                try {
                    thread.wait();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }

        });
       // t.setDaemon(true);
        t.start();

    }
```

## Exchanger
```
private final Exchanger<List> exchanger = new Exchanger();


        new Thread(()->{
            //todo 生产
            while (true){
                try {
                    List<Integer> list=new ArrayList<>();
                    for(int i=0;i<3;i++){
                        list.add(i);
                        System.out.println(Thread.currentThread().getName()+":生产->"+i);
                        DebugUtils.sleep(1);
                    }
                    Object exchange = exchanger.exchange(list);
                    System.out.println(Thread.currentThread().getName() + ":交换完毕-->" + exchange);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }

        }).start();
        new Thread(()->{
            //todo 消费
            while (true) {
                try {
                    List exchange = exchanger.exchange(null);
                    System.out.println(Thread.currentThread().getName() + ":交换完毕-->" + exchange);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }).start();
        synchronized (this){
            try {
                wait();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
   
```

## Thread.join()


### A,B两线程运行，B线程中调用A.join()，则B线程会在A线程执行完后执行
* A.join()会暂停当前执行线程,导致B线程被暂停
* 在A线程结束后，本地方法会唤醒所有本对象（A对象）所暂停的线程，所以B线程被唤醒了
* demo如下，代码将会按顺序输出
```
public static void main(String[] args) {
        Thread t = new Thread(() -> {
            System.out.println("im t1");
        });
        Thread t2 = new Thread(() -> {
            try {
                t.join();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println("im t2");

        });
        t2.start();
        t.start();
        try {
            t2.join();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("im t3");
    }
```

### 源码
```
 public final synchronized void join(final long millis)
    throws InterruptedException {
        if (millis > 0) {
            if (isAlive()) {
                final long startTime = System.nanoTime();
                long delay = millis;
                do {
                    wait(delay);
                } while (isAlive() && (delay = millis -
                        TimeUnit.NANOSECONDS.toMillis(System.nanoTime() - startTime)) > 0);
            }
        } else if (millis == 0) {
            while (isAlive()) {//isAlive判断的是子线程的状态
                wait(0);//wait调用的是父线程的等待，即父线程放弃锁并等待
            }
        } else {
            throw new IllegalArgumentException("timeout value is negative");
        }
    }
```


* 主线程通过c++本地方法唤醒
```
void JavaThread::run() {
  ...
  thread_main_inner();
}

void JavaThread::thread_main_inner() {
  ...
  this->exit(false);
  delete this;
}

void JavaThread::exit(bool destroy_vm, ExitType exit_type) {
  ...
  // Notify waiters on thread object. This has to be done after exit() is called
  // on the thread (if the thread is the last thread in a daemon ThreadGroup the
  // group should have the destroyed bit set before waiters are notified).
  ensure_join(this);
  ...
}

static void ensure_join(JavaThread* thread) {
  // We do not need to grap the Threads_lock, since we are operating on ourself.
  Handle threadObj(thread, thread->threadObj());
  assert(threadObj.not_null(), "java thread object must exist");
  ObjectLocker lock(threadObj, thread);
  // Ignore pending exception (ThreadDeath), since we are exiting anyway
  thread->clear_pending_exception();
  // Thread is exiting. So set thread_status field in  java.lang.Thread class to TERMINATED.
  java_lang_Thread::set_thread_status(threadObj(), java_lang_Thread::TERMINATED);
  // Clear the native thread instance - this makes isAlive return false and allows the join()
  // to complete once we've done the notify_all below
  java_lang_Thread::set_thread(threadObj(), NULL);
  lock.notify_all(thread);//这个位置唤醒了所有线程
  // Ignore pending exception (ThreadDeath), since we are exiting anyway
  thread->clear_pending_exception();
}
```

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

```
public class MyFutureTask extends FutureTask {
    public MyFutureTask(Callable callable) {
        super(callable);
    }

    @Override
    protected void done() {
        System.out.println("任务完成");
        if (!isCancelled()){
            try {
                Object o = get();
                System.out.println(o);
            } catch (InterruptedException e) {
                e.printStackTrace();
            } catch (ExecutionException e) {
                e.printStackTrace();
            }
        }


        super.done();
    }
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
