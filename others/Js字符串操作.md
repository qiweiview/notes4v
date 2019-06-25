
## Js字符串操作

### 查找字符串(获取文件后缀)
```
let name="test.xls";
name.indexOf(".")//-->4
name.slice(4)//--->.xls
name.substr(4)//--->.xls
name.substring(4)//--->.xls
```

### 分割字符串
```
let strArryas="2:3:4:5".split(":");	
```

### 替换字符串
```
str.replace(new RegExp(key,"gm"),to)//把str字符串中符合key的都替换成to
```
