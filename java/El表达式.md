## EL表达式

### 格式化日期
1.  在页面上导入   
```  
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %> 
```
2.  格式化日期
```
<fmt:formatDate value="${XXX.date}" pattern="yyyy-MM-dd"/> 
```

### map取值
直接取map中key=key1 的value
```
${map[key1]}

#例： 
map .put("a","b")
${map["a"]}
```

注意：如果key1 是数值，例如; 1
后台 map.put(1, value1) , 前台${map[1]}将取不到值。原因：**el表达式中数字1是Long类型，无法匹配后台map中的int**。 
修改**map.put(0L,value)**; 前台 ：${map[1]}.