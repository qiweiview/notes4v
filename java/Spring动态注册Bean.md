# Spring动态注册Bean


* 核心思想就是让注册早于AutowiredAnnotationBeanPostProcessor

## 注册bean分为了两种方式：
* DefaultListableBeanFactory接口同时实现了这两个接口


### 使用BeanDefinitionRegistry接口
* Spring容器会根据BeanDefinition实例化bean实例
```
void registerBeanDefinition(String beanName, BeanDefinition beanDefinition) throws BeanDefinitionStoreException
```
### 使用SingletonBeanRegistry接口
* bean实例就是传递给registerSingleton方法的对象
```
void registerSingleton(String beanName, Object singletonObject)
```

## BeanFactoryPostProcessor
* 如果bean不是在BeanFactoryPostProcessor中被注册，那么该bean则无法被**BeanPostProcessor**处理，即无法对其应用aop、Bean Validation等功能
* 在Spring容器的启动过程中，BeanFactory载入bean的定义后会立刻执行BeanFactoryPostProcessor，此时动态注册bean，则可以保证动态注册的bean被BeanPostProcessor处理，并且可以保证其的实例化和初始化总是先于依赖它的bean
* 一定要在postProcessBeanFactory方法里注册对象才可以在后面DI里生效
```
package test;

import kafka.config.Constant;
import kafka.config.ContainerConfig;
import kafka.config.KafkaApplication;
import kafka.consumer.BatchACKListener;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanFactoryPostProcessor;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.beans.factory.support.DefaultListableBeanFactory;


/**
 * 动态注册，调用者应在应用容器里申明该类
 */
public class ConsumerPostProcessor implements BeanFactoryPostProcessor {


    @Override
    public void postProcessBeanFactory(ConfigurableListableBeanFactory configurableListableBeanFactory) throws BeansException {


        DefaultListableBeanFactory defaultListableBeanFactory = (DefaultListableBeanFactory) configurableListableBeanFactory;
        KafkaApplication kafkaApplication = new KafkaApplication(defaultListableBeanFactory);


        ContainerConfig containerConfig = new ContainerConfig(Constant.KAFKA_DEFAULT_TOPIC, Constant.KAFKA_DEFAULT_GROUP_ID);
        BatchACKListener batchACKListener = new BatchACKListener((x) -> {
            Constant.sum.addAndGet(x.size());
            return true;
        });
        containerConfig.setBatchAcknowledgingMessageListener(batchACKListener);
        containerConfig.setThreadNum(10);


        kafkaApplication
                .registerConsumerFactory(Constant.KAFKA_SERVER)
                .registerContainer(containerConfig)
        ;


        defaultListableBeanFactory.registerSingleton("KafkaApplication", kafkaApplication);//注册对象

        System.out.println("All bean has been registered");

    }
}
```


## Bean加载顺序
* BeanFactoryPostProcessor---> xml定义的bean---> 注解@Component定义的bean---> @Configuration定义的bean
* 可以把BeanFactoryPostProcessor申明在xml中或者@Conpoment，或者@Configuration,总是会最先运行
```
BeanFactoryPostProcessor init
Xml bean init
Annotation bean init
Configuration bean init
```


