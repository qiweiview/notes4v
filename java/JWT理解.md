# 设计模式

## 策略模式
### 把鸭容易变化的动作独立出来，以接口形式设置为鸭子类的属性，不同鸭子设置不同接口的实现进去。

1. 找出应用中可能需要变化的地方，把他独立出来，不要和变化的代码混在一起。
2. 针对接口编程，而不是针对实现编程
3. 多用组合，少用继承
范例代码
```
public class Duck {
    FlyBehavior flyBehavior;
    QuackBehavior quackBehavior;

    public void display() {

    }

    public void performQuack() {
        quackBehavior.quack();
    }

    public void performFly() {
        flyBehavior.fly();
    }
}
//详见java_focus项目
```

## 观察者模式

## 装饰者模式
1. 类对拓展开放，对修改关闭