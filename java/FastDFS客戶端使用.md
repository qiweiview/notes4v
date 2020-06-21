# FastDFS客戶端使用

* 依赖包中央仓库可能没有，使用mavne安装


## 工具类
```
package com.zoewin.zephyr.casemanagement.large_file_upload.utils;



import org.csource.fastdfs.*;


import java.io.IOException;



public class FastDFSUtils {
    public static final String GROUP_NAME = "group1";

    static {
        try {
            ClientGlobal.init("fdfs_client.conf");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static String uploadFile(byte[] bytes) {
        return  uploadFile("", bytes);
    }

    public static String uploadFile(String fileExtName, byte[] bytes) {
        if (null == fileExtName) {
            fileExtName = "";
        }
        TrackerClient tracker = new TrackerClient();
        TrackerServer trackerServer = null;
        StorageClient client = null;
        try {
            trackerServer = tracker.getTrackerServer();
            client = new StorageClient(trackerServer, null);
            String[] strings = client.upload_file(GROUP_NAME, bytes, fileExtName, null);
            if (null != strings && strings.length > 1) {
                return strings[1];
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (client != null) {
                    client.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }

        }
        return null;
    }

    public static byte[] downloadFile(String key) {
        TrackerClient tracker = new TrackerClient();
        TrackerServer trackerServer = null;
        StorageClient client = null;
        try {
            trackerServer = tracker.getTrackerServer();
            client = new StorageClient(trackerServer, null);
            byte[] bytes = client.download_file(GROUP_NAME, key);
            return bytes;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (client != null) {
                    client.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }

        }
        return null;

    }

    public static void main(String[] args) {
        byte[] bytes = downloadFile("M00/00/00/ChAAZl7vbnuAQ5WcAAAACTSv3us8312209");
        System.out.println(new String(bytes));

    }
}

```

0. 添加jar包依赖
```
fastdfs-client-java-1.27-RELEASE.jar
```

1. 添加配置文件
```
connect_timeout = 60
network_timeout = 60
charset = UTF-8
http.tracker_http_port = 6666
http.anti_steal_token = no

tracker_server = 123.207.114.245:22122

```
2. 初始化sdk
```
@Bean
    public StorageClient getStorageClient() throws IOException, MyException {
        String filePath = new ClassPathResource("fdfs_client.conf").getFile().getAbsolutePath();
        ClientGlobal.init(filePath);
        TrackerClient trackerClient = new TrackerClient();
        TrackerServer connection = trackerClient.getConnection();
        StorageServer storeStorage = trackerClient.getStoreStorage(connection);
        StorageClient storageClient=new StorageClient(storeStorage,storeStorage);
        return storageClient;
    }
```
3. 上传下载文件
```
  @Autowired
    StorageClient storageClient;



public String uploadFile( @RequestParam(value = "file", required = false) MultipartFile multipartFile) throws IOException, MyException {
        Loog.info(this,multipartFile==null);
        NameValuePair[] meta_list = new NameValuePair[1];
        /*文件属性，以key-value方式存储*/
        meta_list[0] = new NameValuePair("author", "qiwei");
        String fileExtensionName = multipartFile.getOriginalFilename().substring(multipartFile.getOriginalFilename().lastIndexOf(".")-1);//文件拓展名
        Loog.info(this, fileExtensionName);
        String[] strings = storageClient.upload_file(multipartFile.getBytes(), fileExtensionName, meta_list);
        return strings.length > 1 ? strings[0] + "/" + strings[1] : "上传失败";
    }
    
public ResponseEntity<byte[]> downloadFile() throws IOException, MyException {
        byte[] bytes = storageClient.download_file("group1", "M00/00/00/rBAABFvWxv-Aayq-AAITsU1AJ_88.9.jpg");
        HttpHeaders headers = new HttpHeaders();
        headers.setContentDispositionFormData("attachment", new String("M00/00/00/rBAABFvWxv-Aayq-AAITsU1AJ_88.9.jpg".substring("M00/00/00/rBAABFvWxv-Aayq-AAITsU1AJ_88.9.jpg".lastIndexOf(".")).getBytes("UTF-8"), "iso-8859-1"));
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        return new ResponseEntity<>(bytes, headers, HttpStatus.CREATED);
    }
```
