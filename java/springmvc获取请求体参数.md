### springmvc不配置jackson使用@Requestbody会报错，可以使用下面方法直接获取请求体参数

```
BufferedReader br = request.getReader();
String str, wholeStr = "";
while((str = br.readLine()) != null){
wholeStr += str;
}

System.out.println(wholeStr);
```