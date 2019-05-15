# JDK8特性

1. map过滤：
```
Map<String, Integer> collect = checkMap.entrySet()
                        .stream()
                        .filter(k -> k.getValue() == 1)
                        .collect(Collectors.toMap(x -> x.getKey(), x -> x.getValue()));
```