# Spring Shell教程

## 依赖
```
<dependency>
    <groupId>org.springframework.shell</groupId>
    <artifactId>spring-shell-starter</artifactId>
    <version>2.0.0.RELEASE</version>
</dependency>
```

## 注解说明

### @ShellMethod
```
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.METHOD})
@Documented
public @interface ShellMethod {
    String INHERITED = "";

    String[] key() default {};    // 设置命令名称

    String value() default "";    // 设置命名描述

    String prefix() default "--"; // 设置命令参数前缀，默认为“--”

    String group() default "";    // 设置命令分组
}
```

### @ShellOption
* 优先级比@ShellMethod高，会覆盖
```
@ShellMethod(key = {"sum"},value = "do add",prefix = "$")
    public void sum(@ShellOption(arity=3) float[] numbers) {
        System.out.println(numbers[0]+numbers[1]+numbers[2]);
    }
```

## 范例
```
package view.springboot_app_test.shell;

import org.springframework.shell.standard.ShellComponent;
import org.springframework.shell.standard.ShellMethod;
import org.springframework.shell.standard.ShellOption;

@ShellComponent("FShell")
public class FShell {
    @ShellMethod(key = {"add","ad"},value = "相加",prefix = "$")
    public void add(Integer num1,@ShellOption("@b")Integer num2) {
        System.out.println(num1+"+"+num2+"="+(num1+num2));
    }

    @ShellMethod(key = {"hi"},value = "带默认值",prefix = "$")
    public void hi(@ShellOption(defaultValue = "hi") String hi,@ShellOption(defaultValue = "view")String name) {
        System.out.println(hi+name);
    }

    @ShellMethod(key = {"sum"},value = "数组",prefix = "$")
    public void sum(@ShellOption(arity=3) float[] numbers) {
        System.out.println(numbers[0]+numbers[1]+numbers[2]);
    }
}

```



