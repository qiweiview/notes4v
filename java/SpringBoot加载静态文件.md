# SpringBoot加载静态文件


## 配置
```
spring:
  mvc:
    static-path-pattern: /content/** #识别为静态文件的路径开头
  resources:
    static-locations:  classpath:/static #扫描静态文件地址
```

## 使用
```
<script src="/content/axios.min.js"></script>
```
