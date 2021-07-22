# Java读取jar包内文件

```
         URL url = new URL("jar:file:/D:/JAVA_WORK_SPACE/aircraft_carrier/aircraft/target/aircraft.jar!/META-INF/MANIFEST.MF");
        URLConnection urlConnection = url.openConnection();
        new String(IOUtils.toByteArray(urlConnection.getInputStream()));
```
