
## 线程执行可以使用join把主线程加入主线程里，主线程会在所有子线程运行完成后再执行
```
HttpClient client = HttpClient.newHttpClient();
HttpRequest request = HttpRequest.newBuilder()
      .uri(URI.create("http://openjdk.java.net/"))
      .build();
client.sendAsync(request, BodyHandlers.ofString())
      .thenApply(HttpResponse::body)
      .thenAccept(System.out::println)
      .join();
```

### 同步阻塞执行
```
ConcurrentHashMap<String, List<String>> cookieHeaders
                = new ConcurrentHashMap<>();
        MyCookieHandler myCookieHandler = new MyCookieHandler(cookieHeaders);
        HttpClient client = HttpClient.newBuilder()
                .cookieHandler(myCookieHandler)
                .proxy(ProxySelector.of(new InetSocketAddress("39.137.77.66", 8080)))
                .build();
        HttpRequest request = null;
        try {
            request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .header("CooKie", defaultCookie)
                    .headers(defaultHeaders)
                    .build();
        } catch (IllegalArgumentException e) {
            return "";
        }

        HttpResponse<String> httpResponse = client.send(request, HttpResponse.BodyHandlers.ofString());
```
### POST
```
 StringBuilder body = new StringBuilder();
        body.append("{\"author\":\"" + message.getFromUserName() +"\",\"picUrl\":\""+message.getPicUrl()+" \"}");


        HttpClient client = HttpClient.newBuilder()
                .build();
        HttpRequest request = null;
        try {
            request = HttpRequest.newBuilder()
                    .header("Content-Type", "application/json")
                    .uri(URI.create("http://qw607.com:8001/story/addStory4WeChat"))
                    .POST(HttpRequest.BodyPublishers.ofString(body.toString()))
                    .build();
            HttpResponse<String> httpResponse = client.send(request, HttpResponse.BodyHandlers.ofString());
```