# Swagger教程

## 依赖
```
            <dependency>
                <groupId>io.springfox</groupId>
                <artifactId>springfox-boot-starter</artifactId>
                <version>3.0.0</version>
            </dependency>
```

## 注解
```
@Api(value = "培训产出",tags = "培训产出")
public DemoController{
  @ApiOperation(value = "测试接口")
  public void hi(){
  
```
