# ServerSocket SSL

## 创建证数
```
keytool -genkeypair -keyalg RSA -alias selfsigned -keystore keystore.jks  -storepass pass_for_self_signed_cert  -dname "CN=localhost, OU=Developers, O=Bull Bytes, L=Linz, C=AT"
```

## 服务器
```

import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import java.io.*;
import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.security.KeyStore;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class SslBase {
    public static void main(String... args) {
        var address = new InetSocketAddress("0.0.0.0", 8443);

        startSingleThreaded(address);
    }

    public static void startSingleThreaded(InetSocketAddress address) {

        System.out.println("Start single-threaded server at " + address);

        try (var serverSocket = getServerSocket(address)) {

            var encoding = StandardCharsets.UTF_8;

            // This infinite loop is not CPU-intensive since method "accept" blocks
            // until a client has made a connection to the socket
            while (true) {
                try (var socket = serverSocket.accept();
                     // Use the socket to read the client's request
                     var reader = new BufferedReader(new InputStreamReader(
                             socket.getInputStream(), encoding.name()));
                     // Writing to the output stream and then closing it sends
                     // data to the client
                     var writer = new BufferedWriter(new OutputStreamWriter(
                             socket.getOutputStream(), encoding.name()))
                ) {
                    getHeaderLines(reader).forEach(System.out::println);

                    writer.write(getResponse(encoding));
                    writer.flush();

                } catch (IOException e) {
                    System.err.println("Exception while handling connection");
                    e.printStackTrace();
                }
            }
        } catch (Exception e) {
            System.err.println("Could not create socket at " + address);
            e.printStackTrace();
        }
    }

    private static ServerSocket getServerSocket(InetSocketAddress address)
            throws Exception {

        // Backlog is the maximum number of pending connections on the socket,
        // 0 means that an implementation-specific default is used
        int backlog = 0;

        var keyStorePath = Path.of("C:\\Users\\xxx\\Desktop\\xxx\\keystore.jks");
        char[] keyStorePassword = "pass_for_self_signed_cert".toCharArray();

        // Bind the socket to the given port and address
        var serverSocket = getSslContext(keyStorePath, keyStorePassword)
                .getServerSocketFactory()
                .createServerSocket(address.getPort(), backlog, address.getAddress());

        // We don't need the password anymore → Overwrite it
        Arrays.fill(keyStorePassword, '0');

        return serverSocket;
    }

    private static SSLContext getSslContext(Path keyStorePath, char[] keyStorePass)
            throws Exception {

        var keyStore = KeyStore.getInstance("JKS");
        keyStore.load(new FileInputStream(keyStorePath.toFile()), keyStorePass);

        var keyManagerFactory = KeyManagerFactory.getInstance("SunX509");
        keyManagerFactory.init(keyStore, keyStorePass);

        var sslContext = SSLContext.getInstance("TLS");
        // Null means using default implementations for TrustManager and SecureRandom
        sslContext.init(keyManagerFactory.getKeyManagers(), null, null);
        return sslContext;
    }

    private static String getResponse(Charset encoding) {
        var body = "The server says hi 👋\r\n";
        var contentLength = body.getBytes(encoding).length;

        return "HTTP/1.1 200 OK\r\n" +
                String.format("Content-Length: %d\r\n", contentLength) +
                String.format("Content-Type: text/plain; charset=%s\r\n",
                        encoding.displayName()) +
                // An empty line marks the end of the response's header
                "\r\n" +
                body;
    }

    private static List<String> getHeaderLines(BufferedReader reader)
            throws IOException {
        var lines = new ArrayList<String>();
        var line = reader.readLine();
        // An empty line marks the end of the request's header
        while (!line.isEmpty()) {
            lines.add(line);
            line = reader.readLine();
        }
        return lines;
    }
}

```

## 访问
```
https://localhost:8443/
```
