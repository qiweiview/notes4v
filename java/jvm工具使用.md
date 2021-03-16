# jvm调试工具使用

## jmap

* 参数
```
HeapDumpOnOutOfMemoryError
```
* 指令
```
jmap -dump:format=b,file=heapdump.phrof pid
```

##  线程分析 jhat
```
jhat -l pid >> thread_dump
```
