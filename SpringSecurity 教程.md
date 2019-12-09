# SpringSecurity 教程


## [相关包(不仅这些)](https://docs.spring.io/spring-security/site/docs/5.2.1.RELEASE/reference/htmlsingle/#modules)

* spring-security-core.jar 该模块包含核心身份验证和访问控制类和接口，远程支持和基本配置API。使用Spring Security的任何应用程序都需要它。它支持独立的应用程序，远程客户端，方法（服务层）安全性和JDBC
* spring-security-web.jar 该模块包含过滤器和相关的Web安全基础结构代码。它包含任何与Servlet API相关的内容。如果需要Spring Security Web认证服务和基于URL的访问控制，则需要它
* spring-security-config.jar 该模块包含安全名称空间解析代码和Java配置代码。如果您使用Spring Security XML名称空间进行配置或Spring Security的Java配置支持，则需要它
* spring-security-oauth2-core.jar 包含核心类和接口，这些类和接口提供对OAuth 2.0授权框架和OpenID Connect Core 1.0的支持。使用OAuth 2.0或OpenID Connect Core 1.0的应用程序（例如客户端，资源服务器和授权服务器）需要它
* spring-security-oauth2-client.jar 包含Spring Security对OAuth 2.0授权框架和OpenID Connect Core 1.0的客户端支持。
使用OAuth 2.0登录或OAuth客户端支持的应用程序需要使用它


## 主要类概览
* SecurityContextHolder 提供对SecurityContext的访问。
* SecurityContext 保留身份验证和可能特定于请求的安全信息。
* Authentication 以特定于Spring Security的方式代表主体
* GrantedAuthority 反映授予委托人的应用程序范围的权限。
* UserDetails 提供必要的信息以从应用程序的DAO或其他安全数据源构建身份验证对象.
* UserDetailsService 在传递基于字符串的用户名（或证书ID等）时创建UserDetails。


## Authentication
* 实际上，Spring Security并不介意如何将Authentication对象放入SecurityContextHolder中。唯一关键的要求是，SecurityContextHolder包含一个Authentication，它表示要在AbstractSecurityInterceptor（我们将在后面详细介绍）需要授权用户操作之前的主体


## SecurityContextHolder
* 存储上下文，线程安全，通过ThreadLocal保存
* 在SecurityContextHolder内部，我们存储了当前与应用程序交互的主体的详细信息。
```
Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();

if (principal instanceof UserDetails) {
String username = ((UserDetails)principal).getUsername();
} else {
String username = principal.toString();
}
```

## UserDetailsService
* UserDetails是Spring Security中的核心接口。它代表一个原理，但以一种可扩展的和特定于应用程序的方式。将UserDetails视为您自己的用户数据库和SecurityContextHolder内部Spring Security所需的适配器。作为您自己的用户数据库中某物的表示，通常您会将UserDetails转换为应用程序提供的原始对象，因此您可以调用特定于业务的方法
* 身份验证成功后，将使用UserDetails来构建存储在SecurityContextHolder中的Authentication对象
* UserDetailsService此接口上的唯一方法接受基于字符串的用户名参数，并返回UserDetails
```
UserDetails loadUserByUsername(String username) throws UsernameNotFoundException;
```
* 关于UserDetailsS​​ervice经常会有一些困惑。它纯粹是用于用户数据的DAO，除了将数据提供给框架内的其他组件外，不执行其他功能。
特别是，它不对用户进行身份验证，这由AuthenticationManager完成。在许多情况下，如果您需要自定义身份验证过程，则直接实现AuthenticationProvider更有意义。
* 我们提供了许多UserDetailsService实现，其中一个使用内存映射（InMemoryDaoImpl），另一个使用JDBC（JdbcDaoImpl）。

## GrantedAuthority
* GrantedAuthority对象通常由UserDetailsService加载


## ExceptionTranslationFilter
* ExceptionTranslationFilter是一个Spring Security过滤器，负责检测抛出的任何Spring Security异常。此类异常通常由AbstractSecurityInterceptor抛出，AbstractSecurityInterceptor是授权服务的主要提供者

## AuthenticationEntryPoint
* 每个主要的身份验证系统都有其自己的AuthenticationEntryPoint实现

## AuthenticationManager 
* Spring Security中的默认实现称为ProviderManager
* 验证身份验证请求的最常见方法是加载相应的UserDetails，并对照用户输入的密码检查加载的密码。
这是DaoAuthenticationProvider使用的方法（请参见下文）。
构建完整填充的Authentication对象时，将使用加载的UserDetails对象（尤其是其中包含的GrantedAuthority），该对象将从成功的身份验证返回并存储在SecurityContext中。

## ProviderManager 
* ProviderManager将尝试从Authentication对象中清除所有敏感的凭据信息，该信息由成功的身份验证请求返回。
这样可以防止将密码之类的信息保留的时间过长。

## DaoAuthenticationProvider
* Spring Security实现的最简单的AuthenticationProvider是DaoAuthenticationProvider，它也是框架最早支持的之一
* 只需将UsernamePasswordAuthenticationToken中提交的密码与UserDetailsService加载的密码进行比较，即可对用户进行身份验证

## UserDetailsService 
```
UserDetails loadUserByUsername(String username) throws UsernameNotFoundException;
```
* 返回的UserDetails是一个提供获取器的接口，该获取器保证以非空方式提供身份验证信息，例如用户名，密码，授予的权限以及是否启用或禁用用户帐户
* 大多数身份验证提供程序将使用UserDetailsS​​ervice，即使用户名和密码实际上并未用作身份验证决定的一部分
* 他们可能仅将返回的UserDetails对象用于其GrantedAuthority信息，因为某些其他系统（例如LDAP或X.509或CAS等）承担了实际验证凭据的责任。


## PasswordEncoder 
* PasswordEncoder接口用于对密码进行单向转换，以确保密码可以安全地存储
* 通常，PasswordEncoder用于存储需要在身份验证时与用户提供的密码进行比较的密码。
* 在Spring Security 5.0之前，默认的PasswordEncoder是NoOpPasswordEncoder，它需要纯文本密码
* 您可以使用PasswordEncoderFactories轻松构造DelegatingPasswordEncoder的实例
```
PasswordEncoder passwordEncoder = PasswordEncoderFactories.createDelegatingPasswordEncoder();

# 创建自己的实例
String idForEncode = "bcrypt";
Map encoders = new HashMap<>();
encoders.put(idForEncode, new BCryptPasswordEncoder());
encoders.put("noop", NoOpPasswordEncoder.getInstance());
encoders.put("pbkdf2", new Pbkdf2PasswordEncoder());
encoders.put("scrypt", new SCryptPasswordEncoder());
encoders.put("sha256", new StandardPasswordEncoder());

PasswordEncoder passwordEncoder =
    new DelegatingPasswordEncoder(idForEncode, encoders);
```

* 密码存储格式
```
# id是用于查找应使用哪个PasswordEncoder的标识符，而encodePassword是所选PasswordEncoder的原始编码密码,如果找不到该id，则该id将为null。
{id}encodedPassword 

#BCryptPasswordEncoder
{bcrypt}$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG 1

#NoOpPasswordEncoder
{noop}password 2

#Pbkdf2PasswordEncoder
{pbkdf2}5d923b44a6d129f3ddf3e3c8d29412723dcbde72445e8ef6bf3b508fbf17fa4ed4d6b99ca763d8dc 3

#SCryptPasswordEncoder
{scrypt}$e0801$8bWJaSu2IKSn9Z9kM+TPXfOc/9bdYSrN1oD9qfVThWEwdRTnO7re7Ei+fUZRJ68k9lTyuTeUp4of4g24hHnazw==$OAOec05+bXxvuu/1qZ6NUR+xQYvYv7BeL1QxwRpY5Pc=  4

#StandardPasswordEncoder
{sha256}97cde38028ad898ebc02e690819fa220e88c62e0699403e94fff291cfffaf8410849f27605abcbc0 5
```
* 密码匹配
```
#匹配是基于{id}和id到构造函数中提供的PasswordEncoder的映射完成的。
# 默认情况下，使用密码和未映射的ID（包括空ID）调用match（CharSequence，String）的结果将导致IllegalArgumentException。
可以使用DelegatingPasswordEncoder.setDefaultPasswordEncoderForMatches（PasswordEncoder）自定义此行为。
```








## 流程Demo
* 获取用户名和密码，并将其组合到UsernamePasswordAuthenticationToken实例
* 令牌将传递到AuthenticationManager实例进行验证。
* AuthenticationManager 返回一个填充的Authentication 实例在验证成功后
* 通过调用SecurityContextHolder.getContext（）。setAuthentication（…）来建立安全上下文，并传入返回的身份验证对象。
```
package qw607.jarvis.config;

import org.springframework.security.authentication.*;
import org.springframework.security.core.*;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import java.util.ArrayList;
import java.util.List;

public class AuthenticationExample {
    private static AuthenticationManager authenticate = new SampleAuthenticationManager();

    public static void main(String[] args) throws Exception {



        String name = "123";
        System.out.println("username:"+name);
        String password = "1231";
        System.out.println("password:"+password);
        try {
            Authentication request = new UsernamePasswordAuthenticationToken(name, password);
            Authentication result = authenticate.authenticate(request);
            SecurityContextHolder.getContext().setAuthentication(result);
            System.out.println("Successfully authenticated. Security context contains: " +
                    SecurityContextHolder.getContext().getAuthentication());
        } catch (AuthenticationException e) {
            System.out.println("Authentication failed: " + e.getMessage());
        }

    }
}

class SampleAuthenticationManager implements AuthenticationManager {
    static final List<GrantedAuthority> AUTHORITIES = new ArrayList<>();

    static {
        AUTHORITIES.add(new SimpleGrantedAuthority("ROLE_USER"));
    }


    @Override
    public Authentication authenticate(Authentication auth) throws AuthenticationException {
        if (auth.getName().equals(auth.getCredentials())) {
            return new UsernamePasswordAuthenticationToken(auth.getName(),
                    auth.getCredentials(), AUTHORITIES);
        }
        throw new BadCredentialsException("Bad Credentials");
    }
}
```




## 认证方式
### In-Memory Authentication 方式
```
@Bean
public UserDetailsService userDetailsService() throws Exception {
    // ensure the passwords are encoded properly
    UserBuilder users = User.withDefaultPasswordEncoder();
    InMemoryUserDetailsManager manager = new InMemoryUserDetailsManager();
    manager.createUser(users.username("user").password("password").roles("USER").build());
    manager.createUser(users.username("admin").password("password").roles("USER","ADMIN").build());
    return manager;
}
```

### JDBC Authentication 方式
```
@Autowired
private DataSource dataSource;

@Autowired
public void configureGlobal(AuthenticationManagerBuilder auth) throws Exception {
    // ensure the passwords are encoded properly
    UserBuilder users = User.withDefaultPasswordEncoder();
    auth
        .jdbcAuthentication()
            .dataSource(dataSource)
            .withDefaultSchema()
            .withUser(users.username("user").password("password").roles("USER"))
            .withUser(users.username("admin").password("password").roles("USER","ADMIN"));
}
```

## 会话管理
* HTTP会话相关的功能由SessionManagementFilter和SessionAuthenticationStrategy接口的组合来处理，该接口将过滤器委托给该接口



## 表单登陆
### WebSecurityConfigurerAdapter 
* 当我们想要更改默认配置时，我们可以通过扩展它来定制我们前面提到的WebSecurityConfigurerAdapter
```
protected void configure(HttpSecurity http) throws Exception {
    http
        .authorizeRequests(authorizeRequests ->
            authorizeRequests
                .anyRequest().authenticated()
        )
        .formLogin(formLogin ->
            formLogin
                .loginPage("/login") 1
                .permitAll()         2
        );
}




protected void configure(HttpSecurity http) throws Exception {
    http
        .logout(logout ->                                                       1
            logout
                .logoutUrl("/my/logout")                                        2
                .logoutSuccessUrl("/my/index")                                  3
                .logoutSuccessHandler(logoutSuccessHandler)                     4
                .invalidateHttpSession(true)                                    5
                .addLogoutHandler(logoutHandler)                                6
                .deleteCookies(cookieNamesToClear)                              7
        )
        ...
}
```

# Java配置
