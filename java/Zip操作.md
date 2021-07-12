# Zip操作
## 解压
```
                    ZipInputStream zipStream = new ZipInputStream(inputStream);
                    ZipEntry entry = null;
                    try {
                        while ((entry = zipStream.getNextEntry()) != null) {

                            String name = entry.getName();
                            if (entry.isDirectory()) {
                                //todo 文件夹
                           
                            } else {
                                //todo 文件
                                byte[] bytes = StreamUtils.readAllBytes(zipStream);

                            }

                        }
                        return;
                    } catch (Exception e) {
                        e.printStackTrace();
                        throw new RuntimeException("load fail cause:" + e);
                    }
```

## 压缩
```
public static void zipFiles(List<OutPutTask> collect, File zipfile) {
        try {
            //ZipOutputStream类：完成文件或文件夹的压缩
            ZipOutputStream out = new ZipOutputStream(new FileOutputStream(zipfile));
            for (OutPutTask file : collect) {
                out.putNextEntry(new ZipEntry(file.getRelativelyPath()));
                out.write(file.toByte());
                out.closeEntry();
            }
            out.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
```

## 预览ZIP文件结构

* key值为路径,value则为路径下所有文件
* 【dir】标识的为文件夹
```

import java.io.File;
import java.io.IOException;
import java.util.*;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

public class ZipTest {
    public static void main(String[] args) throws IOException {
        String path="C:\\Users\\xxxxx\\Desktop\\com.zip";

        File file = new File(path);
        ZipFile zip = new ZipFile(file);
        Enumeration<? extends ZipEntry> entries = zip.entries();
        Map<String, List<String>> map=new HashMap<>();
        while (entries.hasMoreElements()){
            ZipEntry  zipEntry = entries.nextElement();
            if (zipEntry.isDirectory()){
                //todo mkdir if empty
                String dir = zipEntry.getName();
                dir= dir.substring(0,dir.lastIndexOf("/"));
                if (dir.indexOf("/")!=-1){
                    String fDir = dir.substring(0,dir.lastIndexOf("/")+1);
                    String sDir = "【dir】"+dir.substring(dir.lastIndexOf("/")+1);
                    List<String> list = map.get(fDir);
                    if (list==null){
                        list=new ArrayList<>();
                        map.put(fDir,list);
                    }
                    list.add(sDir);
                }
                

            }else {
                String name = zipEntry.getName();
               String dir= name.substring(0,name.lastIndexOf("/")+1);
                String fileName = name.substring(name.lastIndexOf("/")+1);
                List<String> list = map.get(dir);
                if (list==null){
                    list=new ArrayList<>();
                    map.put(dir,list);
                }
                list.add(fileName);
            }

        }

        map.forEach((k,v)->{
            System.out.println(k+"==>"+v);
        });

    }
}

```
