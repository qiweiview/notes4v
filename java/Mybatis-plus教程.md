# mybatis-plus教程

* 在 MyBatis 的基础上只做增强不做改变，为简化开发、提高效率而生

## 依赖
```
<dependency>
      <groupId>com.baomidou</groupId>
      <artifactId>mybatis-plus</artifactId>
      <version>3.1.2</version>
</dependency>
```

## 配置
* 把Mybatis(mybatis-spring)的工厂替换成mybatis-plus的工厂,其他配置和mybatis-spring一样
```
@Bean
  public SqlSessionFactory mybatisPlusFactory() throws Exception {
    MybatisSqlSessionFactoryBean mybatisSqlSessionFactoryBean = new MybatisSqlSessionFactoryBean();
    mybatisSqlSessionFactoryBean.setDataSource(getDataSource());
    mybatisSqlSessionFactoryBean.setPlugins(Arrays.array(paginationInterceptor()));//分页插件
    return mybatisSqlSessionFactoryBean.getObject();
  }
```
* 配置mappes扫描
```
@MapperScan(basePackages = "test4v")
```
* Mapper编写
```
package test4v;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
public interface UserMapper3 extends BaseMapper<MyUser> {
}

```

* 实体类注解配置
```
package test4v;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;

@TableName(value = "user")//指定表名
public class MyUser {
  @TableId(value = "id", type = IdType.UUID)//指定自增策略
  private String id;
  @TableField(value = "username")
  private String username;
  @TableField(value = "createDate")
  private String createDate;
```




## 查询
```
@Autowired
UserMapper3 userMapper3;
  
public void doQuery() {
    QueryWrapper<MyUser> like = Wrappers.<MyUser>query().like("username", "大头");
    List<MyUser> myUsers = userMapper3.selectList(like );
    myUsers.forEach(System.out::println);
  }
```
## 分页查询
* 插件物理分页，内存分页在数据量大的时候会导致内存溢出

* 注册分页插件
```
@Bean
  public PaginationInterceptor paginationInterceptor() {
    PaginationInterceptor paginationInterceptor = new PaginationInterceptor();
    // paginationInterceptor.setLimit(你的最大单页限制数量，默认 500 条，小于 0 如 -1 不受限制);
    return paginationInterceptor;
  }
```
* 配置分页插件
```
@Bean
  public SqlSessionFactory mybatisPlusFactory() throws Exception {
    MybatisSqlSessionFactoryBean mybatisSqlSessionFactoryBean = new MybatisSqlSessionFactoryBean();
    mybatisSqlSessionFactoryBean.setDataSource(getDataSource());
    mybatisSqlSessionFactoryBean.setPlugins(Arrays.array(paginationInterceptor()));
    return mybatisSqlSessionFactoryBean.getObject();
  }
```
* 分页查询
```
 public void doQuery() {
    QueryWrapper<MyUser> like = Wrappers.<MyUser>query().like("username", "大头");
    Page<MyUser> myUserPage = (Page<MyUser>) userMapper3.selectPage(new Page<>(1,4), null);
    System.out.println(myUserPage.getRecords().size());
  }
```


## 插入
```
MyUser myUser=new MyUser();
    myUser.setUsername("大头11");
    myUser.setCreateDate("今天");
    userMapper3.insert(myUser);
```


## Service 接口CURD
* 通用 Service CRUD 封装IService接口，进一步封装 CRUD 采用 get 查询单行 remove 删除 list 查询集合 page 分页 
* 前缀命名方式区分 Mapper 层避免混淆
* ServiceImpl对象内部持有一个mapper,方法还是 
```
package test4v;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;

@Service
public class MyServiceImpl extends ServiceImpl<UserMapper3,MyUser> {

  
}
```

* 通过sevice接口进行批量添加
```
@Autowired
IService  myService;


@Transactional
  public void doInsert() {
    List<MyUser> collect = Stream.iterate(new MyUser(UUID.randomUUID()+"大头"), x -> {
     return new MyUser(UUID.randomUUID()+"大头");
    }).limit(20).collect(Collectors.toList());
    myService.saveBatch(collect);
  }
  
```
* 通过sevice接口进行分页查询（也是要事先配插件物理分页）
```
  public void doQuery() {
    IPage<MyUser> page = myService.page(new Page<>(1, 4));
    System.out.println(page.getRecords().size());
  }
```


## Lamda
```
 public void doQuery() {
    LambdaQueryWrapper<MyUser> lmd = Wrappers.<MyUser>lambdaQuery().like(MyUser::getUsername, "大头");
    
    Page<MyUser> myUserPage = (Page<MyUser>) userMapper3.selectPage(new Page<>(0, 4), lmd);
    System.out.println(myUserPage.getRecords().size());
   
    IPage<MyUser> page = myService.page(new Page<>(0, 4), lmd);
    System.out.println(page.getRecords().size());
   
    IPage<MyUser> lmqq = myService.lambdaQuery().like(MyUser::getUsername, "大头").page(new Page<>(0, 4));
    System.out.println(lmqq.getRecords().size());
  }
```

## [条件构造器见文档](https://mp.baomidou.com/guide/wrapper.html#abstractwrapper)


## [接口详见文档](https://mp.baomidou.com/guide/crud-interface.html)


待使用完善...




