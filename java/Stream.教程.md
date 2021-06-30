# Stream教程

## flapMap
```
        List<String> d=new ArrayList<>();
        d.add("AF,FG");
        d.add("DT,AJ");
        d.add("DT,ZLS");
        d.add("XZ,LF");

        List<String> collect = d.stream().flatMap(x -> {
            return Stream.of(x.split(","));
        }).collect(Collectors.toList());
        System.out.println(collect);

        //[AF, FG, DT, AJ, DT, ZLS, XZ, LF]
```

## 分组
```
  Map<String, List<DemoVO>> collect = load.stream().collect(Collectors.groupingBy(x -> x.getBusinessCode()));
```

## collect
* collect()方法可以对stream中的元素进行各种处理后，得到stream中元素的值。并且Collectors接口提供了很方便的创建Collector对象的工厂方法。
```
    @Test
    public void collectTest() {
        List<String> list = Stream.of("hello", "world", "hello", "java").collect(Collectors.toList());
        list.forEach(x -> System.out.print(x + " "));
        System.out.println();
        Set<String> set = Stream.of("hello", "world", "hello", "java").collect(Collectors.toSet());
        set.forEach(x -> System.out.print(x + " "));
        System.out.println();
        Set<String> treeset = Stream.of("hello", "world", "hello", "java").collect(Collectors.toCollection(TreeSet::new));
        treeset.forEach(x -> System.out.print(x + " "));
        System.out.println();
        String resultStr = Stream.of("hello", "world", "hello", "java").collect(Collectors.joining(","));
        System.out.println(resultStr);
    }
```
