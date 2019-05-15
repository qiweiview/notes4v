
在方法中添加回调参数，并在成功后回调
```
function testAjax(handleData) {
  $.ajax({
    url:"getvalue.php",  
    success:function(data) {
      handleData(data); 
    }
  });
}
```

调用
```
testAjax(function(output){
  // here you use the output
});

```