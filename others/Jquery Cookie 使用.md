## 引入
```
<script src="https://cdn.bootcss.com/jquery/3.3.1/jquery.min.js"></script>
<script src="https://cdn.bootcss.com/jquery-cookie/1.4.1/jquery.cookie.min.js"></script>
```
## 添加Cookie
```
  $.cookie('history', strHistory, {expires: 365});
```
## 删除Cookie
```
 $.cookie('history', null, {expires: -1});
```