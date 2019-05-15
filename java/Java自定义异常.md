## Runtime Exception： 
在定义方法时不需要声明会抛出runtime exception； 在调用这个方法时不需要捕获这个runtime exception； runtime exception是从java.lang.RuntimeException或java.lang.Error类衍生出来的。 例如：nullpointexception，IndexOutOfBoundsException就属于runtime exception 

## Exception:
定义方法时必须声明所有可能会抛出的exception； 在调用这个方法时，必须捕获它的checked exception，不然就得把它的exception传递下去；exception是从java.lang.Exception类衍生出来的。例如：IOException，SQLException就属于Exception

### 示例
```
/**
 * 未检测出注解抛出异常
 * @author liuqiwei
 *
 */
public class NoAnnotationException extends Exception{

	public NoAnnotationException() {
		super();
	}
	public NoAnnotationException(String message) {
		super(message);
	}
}
```