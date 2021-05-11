# 读取properties文件

```
  Properties prop = new Properties();
        InputStream resourceAsStream = AESUtils.class.getClassLoader().getResourceAsStream("config.properties");
        if (resourceAsStream != null) {
            try {
                prop.load(resourceAsStream);
                String aesKey = prop.getProperty("AESKey");
                key = aesKey.getBytes();
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }
```
