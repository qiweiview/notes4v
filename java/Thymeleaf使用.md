# Thymeleaf使用

## 获取绝对路径
1. 在script标签添加
```
th:inline="javascript"
```

2. Js代码里添加

```
var basePath = /*[[${#httpServletRequest.getScheme() + "://" + #httpServletRequest.getServerName() + ":" + #httpServletRequest.getServerPort() + #httpServletRequest.getContextPath()}]]*/;
```

获取Moel参数

Controller
```
  model.addAttribute("mailCode",mailCode);
  
```

前台
```
 <span th:text="${mailCode}"></span>
 
```

javascript
```
<script th:inline="javascript">


    let mailCode = /*[[${mailCode}]]*/ 'default';
    console.log(message);


</script>
```