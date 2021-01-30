# Java引用


* 软引用可以和一个引用队列（ReferenceQueue）联合使用，如果软引用所引用的对象被垃圾回收
* Java虚拟机就会把这个软引用加入到与之关联的引用队列中
```
 Object obj = new Object();
        ReferenceQueue<Object> refQueue = new ReferenceQueue<Object>();
        SoftReference<Object> softRef = new SoftReference<Object>(obj, refQueue);
        System.out.println(softRef.get()); // java.lang.Object@f9f9d8
        System.out.println(refQueue.poll());// null

        // 清除强引用,触发GC
        obj = null;
        System.gc();

        System.out.println(softRef.get());

        Thread.sleep(200);
        System.out.println(refQueue.poll());
```
