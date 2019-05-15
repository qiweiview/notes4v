## 后台代码

```java
//上传controller  
@ResponseBody
    @RequestMapping(value = "/upload")
    public String upload(HttpServletRequest request, @RequestParam(value = "file", required = false) MultipartFile multipartFile) throws IOException {
        String originalFilename = multipartFile.getOriginalFilename();
        String directPath = getServerPath(request);
        System.out.println(directPath + "\\" + originalFilename);
        File file = new File(directPath);
        if (!file.exists()) {
            file.mkdirs();
        }
        String filePath = directPath + "\\" + originalFilename;
        File targetFile = new File(filePath);
        multipartFile.transferTo(targetFile);
        FileNameCache.addFile(originalFilename, "/uploadPool/" + originalFilename);
        return "suc";
    }
//获取地址，springboot项目静态资源默认在static里面
/**
     * 获取部署位置同级目录
     *
     * @param request
     * @return
     */
    private String getServerPath(HttpServletRequest request) throws FileNotFoundException {
        Object server_path = request.getSession().getAttribute("SERVER_PATH");
        if (server_path != null) {
            return server_path.toString();
        } else {
           /* 获取springboot上传文件地址*/
            String path = ResourceUtils.getFile(ResourceUtils.CLASSPATH_URL_PREFIX + "static/uploadPool/").getPath();
            request.getSession().setAttribute("SERVER_PATH", path);
            return path;
        }

    }
```
(value = "file", required = false)不写会报400错误


## 修改springboot上传大小限制
```xml
//Spring Boot 1.3.x及更早版本
multipart.maxFileSize
multipart.maxRequestSize

//Spring Boot 1.4.x和1.5.x.
spring.http.multipart.maxFileSize
spring.http.multipart.maxRequestSize

//Spring Boot 2.x
spring.servlet.multipart.maxFileSize
spring.servlet.multipart.maxRequestSize
```

## 异步上传
```javascript
function doUpload() {
        let form = new FormData();

        for (k in $('#uploadForm')[0].files) {
            if (k != "length" && k != "item") {
                form.append("file", $('#uploadForm')[0].files[k]);
            }
        }

        form.append("name", "view");
        $.ajax({
            url: '/uploadController/doUpload',
            type: 'POST',
            cache: false,
            data: form,
            processData: false,
            contentType: false
        }).done(function (res) {
            console.log(res)
        }).fail(function (res) {
            alert("error")
        });
    }
```

### 后台
```
 @RequestMapping(path = "/doUpload", method = RequestMethod.POST)
    @ResponseBody
    public MyResponse doUpload(@RequestParam("name") String name, @RequestParam("file") MultipartFile[] file) throws IOException {

        System.out.println("name;"+name);
        System.out.println("文件个数"+file.length);

        return new MyResponse(0,"suc","123");
    }
```