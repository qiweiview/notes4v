# Zip操作
## 压缩工具
```
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import java.util.zip.ZipOutputStream;
import org.apache.tools.zip.ZipEntry;
import org.apache.tools.zip.ZipFile;

public class ZipUtil {
    private static final int buffer = 2048;

    public ZipUtil() {
    }

    /** @deprecated */
    @Deprecated
    public static void unZipFiles(String zipPath, String descDir) throws IOException {
        unZipFiles(new File(zipPath), descDir);
    }

    public static void unZipFiles(File zipFile, String descDir) throws IOException {
        File pathFile = new File(descDir);
        if (!pathFile.exists()) {
            pathFile.mkdirs();
        }

        ZipFile zip = new ZipFile(zipFile);
        Enumeration entries = zip.getEntries();

        while(true) {
            InputStream in;
            String outPath;
            do {
                if (!entries.hasMoreElements()) {
                    return;
                }

                ZipEntry entry = (ZipEntry)entries.nextElement();
                String zipEntryName = entry.getName();
                in = zip.getInputStream(entry);
                outPath = (descDir + zipEntryName).replaceAll("\\*", "/");
                outPath = new String(outPath.getBytes("utf-8"), "ISO8859-1");
                File file = new File(outPath.substring(0, outPath.lastIndexOf(47)));
                if (!file.exists()) {
                    file.mkdirs();
                }
            } while((new File(outPath)).isDirectory());

            OutputStream out = new FileOutputStream(outPath);
            byte[] buf1 = new byte[1024];

            int len;
            while((len = in.read(buf1)) > 0) {
                out.write(buf1, 0, len);
            }

            in.close();
            out.close();
        }
    }

    public static void compress(String source, String destinct) throws IOException {
        List fileList = loadFilename(new File(source));
        ZipOutputStream zos = new ZipOutputStream(new FileOutputStream(new File(destinct)));
        byte[] buffere = new byte[8192];

        for(int i = 0; i < fileList.size(); ++i) {
            File file = (File)fileList.get(i);
            zos.putNextEntry(new ZipEntry(getEntryName(source, file)));
            BufferedInputStream bis = new BufferedInputStream(new FileInputStream(file));

            while(true) {
                int length = bis.read(buffere);
                if (length == -1) {
                    bis.close();
                    zos.closeEntry();
                    break;
                }

                zos.write(buffere, 0, length);
            }
        }

        zos.close();
    }

    private static List loadFilename(File file) {
        List filenameList = new ArrayList();
        if (file.isFile()) {
            filenameList.add(file);
        }

        if (file.isDirectory()) {
            File[] var2 = file.listFiles();
            int var3 = var2.length;

            for(int var4 = 0; var4 < var3; ++var4) {
                File f = var2[var4];
                filenameList.addAll(loadFilename(f));
            }
        }

        return filenameList;
    }

    private static String getEntryName(String base, File file) {
        File baseFile = new File(base);
        String filename = file.getPath();
        return baseFile.getParentFile().getParentFile() == null ? filename.substring(baseFile.getParent().length()) : filename.substring(baseFile.getParent().length() + 1);
    }

    public static void main(String[] args) throws IOException {
        unZip("D:/saas-plugin-web-master-shiro-mybatis.zip", "D:/123");
    }

    public static void unZip(String path, String savepath) {
        int count = true;
        File file = null;
        InputStream is = null;
        FileOutputStream fos = null;
        BufferedOutputStream bos = null;
        (new File(savepath)).mkdir();
        ZipFile zipFile = null;

        try {
            zipFile = new ZipFile(path, "gbk");
            Enumeration entries = zipFile.getEntries();

            while(true) {
                while(entries.hasMoreElements()) {
                    byte[] buf = new byte[2048];
                    ZipEntry entry = (ZipEntry)entries.nextElement();
                    String filename = entry.getName();
                    boolean ismkdir = false;
                    if (filename.lastIndexOf("/") != -1) {
                        ismkdir = true;
                    }

                    filename = savepath + filename;
                    if (entry.isDirectory()) {
                        file = new File(filename);
                        file.mkdirs();
                    } else {
                        file = new File(filename);
                        if (!file.exists() && ismkdir) {
                            (new File(filename.substring(0, filename.lastIndexOf("/")))).mkdirs();
                        }

                        file.createNewFile();
                        is = zipFile.getInputStream(entry);
                        fos = new FileOutputStream(file);
                        bos = new BufferedOutputStream(fos, 2048);

                        int count;
                        while((count = is.read(buf)) > -1) {
                            bos.write(buf, 0, count);
                        }

                        bos.flush();
                        bos.close();
                        fos.close();
                        is.close();
                    }
                }

                zipFile.close();
                break;
            }
        } catch (IOException var21) {
            var21.printStackTrace();
        } finally {
            try {
                if (bos != null) {
                    bos.close();
                }

                if (fos != null) {
                    fos.close();
                }

                if (is != null) {
                    is.close();
                }

                if (zipFile != null) {
                    zipFile.close();
                }
            } catch (Exception var20) {
                var20.printStackTrace();
            }

        }

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
