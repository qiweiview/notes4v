# Sun原生HttpServer
```

import com.sun.net.httpserver.HttpContext;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;
import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;


public class HttpServerTest {
    public static void main(String[] args) throws IOException {

        HttpServer httpServer = HttpServer.create(new InetSocketAddress(80), 0);
        HttpHandler httpHandler = new HttpHandler() {
            @Override
            public void handle(HttpExchange httpExchange) throws IOException {
                StringBuilder response = new StringBuilder();
                response.append("<html><body>");
                response.append("hello ");
                response.append("</body></html>");
                httpExchange.sendResponseHeaders(200, response.length());
                OutputStream os = httpExchange.getResponseBody();
                os.write(response.toString().getBytes());
                os.close();

            }
        };
        HttpContext context = httpServer.createContext("/test", httpHandler);
        httpServer.setExecutor(null); // creates a default executor
        httpServer.start();

    }
}

```
