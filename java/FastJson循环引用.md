## 循环引用会引起输出结果出现$ref":"$[0].menus[0]


### 通过对toJasonString方法添加参数
```
SerializerFeature.DisableCircularReferenceDetect
即：
JSON.toJSONString(String, SerializerFeature.DisableCircularReferenceDetect);
```

可以解决