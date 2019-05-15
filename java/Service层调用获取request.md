# Service层调用获取request
通过

```
((ServletRequestAttributes)RequestContextHolder.getRequestAttributes()).getRequest();
```
是线程安全的