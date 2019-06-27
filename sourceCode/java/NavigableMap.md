# NavigableMap


## 方法

### lowerEntry(K key)返回与严格小于给定键的最大键相关联的键 - 值映射，如果没有这样的键，则返回null
```
Map.Entry<K,V> lowerEntry(K key);
```

### lowerKey(K key)返回严格小于给定键的最大键，如果没有这样键，则返回null
```
K lowerKey(K key);
```

### floorEntry(K key)返回与小于或等于给定键的最大键关联的键 - 值映射，如果没有此键，则返回null
```
Map.Entry<K,V> floorEntry(K key);
```

### floorKey(K key)返回小于或等于给定键的最大键，如果没有这样的键，则返回null
```
 K floorKey(K key);
```

### ceilingEntry(K key)返回与大于或等于给定键的最小键关联的键 - 值映射，如果没有这样的键，则返回null
```
 Map.Entry<K,V> ceilingEntry(K key);
```

### ceilingKey(K key)返回大于或等于给定键的最小键，如果没有这样键，则返回null 
```
K ceilingKey(K key);
```

### higherEntry(K key)返回与严格大于给定键的最小键关联的键 - 值映射，如果没有这样的键，则返回null
```
 Map.Entry<K,V> higherEntry(K key);
```

### higherKey(K key)返回严格大于给定键的最小键，如果没有这样键，则返回null
```
  K higherKey(K key);
```

### 返回与此映射中的最小键关联的键 - 值映射，如果映射为空，则返回null
```
 Map.Entry<K,V> firstEntry();
```
### 返回与此映射中的最大键关联的键 - 值映射，如果映射为空，则返回null
```
 Map.Entry<K,V> lastEntry();
```

### pollFirstEntry()删除并返回与此映射中的最小键关联的键 - 值映射，如果映射为空，则返回null
```
 Map.Entry<K,V> pollFirstEntry();
```

### pollLastEntry()删除并返回与此映射中的最大键关联的键 - 值映射，如果映射为空，则返回null
```
 Map.Entry<K,V> pollLastEntry();
```

### descendingMap()返回此映射中包含的映射的逆序视图
```
NavigableMap<K,V> descendingMap();
```

### navigableKeySet()返回此映射中包含的键的NavigableSet视图
```
 NavigableSet<K> navigableKeySet();
```

### descendingKeySet()返回此映射中包含的键的反向顺序NavigableSet视图
```
  NavigableSet<K> descendingKeySet();
```


### subMap(K fromKey, boolean fromInclusive, K toKey,   boolean toInclusive)

* 返回此映射部分的视图，其键的范围从fromKey到toKey。 如果fromKey和toKey相等，则返回的映射为空.除非fromInclusive和toInclusive都为真
```
NavigableMap<K,V> subMap(K fromKey, boolean fromInclusive, K toKey,   boolean toInclusive);
```

#### headMap(K toKey, boolean inclusive)

* 返回此映射的部分视图，其键小于（或等于，如果inclusive为true）
```
NavigableMap<K,V> headMap(K toKey, boolean inclusive);
```

### tailMap(K fromKey, boolean inclusive)

* 返回此映射的部分视图，其键大于（或等于，如果inclusive为true）
```
NavigableMap<K,V> tailMap(K fromKey, boolean inclusive);
```

