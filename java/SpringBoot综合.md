# SpringBoot综合

## springboot 加载resource目录下的文件
```
            byte[] bytes = new byte[1024 * 1024];
            InputStream stream = getClass().getClassLoader().getResourceAsStream("/template/培训签到表模板.xlsx");
            int read = stream.read(bytes);
            byte[] templateByte = Arrays.copyOf(bytes, read);
```
