# Try_Catch教程

## 经典几个场景
* 类
```
public class TryReturn {

    int i1;
```

* finally 内操作不影响返回值
```
    public int doWork() {
        try {
            i1 = 1;
            return i1;
        } catch (Exception e) {
            return 2;
        } finally {
            i1 = 666;
        }
    }

```

* finallly内返回会直接返回,优先级较高
```
    //范例一
    public int doWork() {
        try {
            i1 = 1;
            return i1;
        } catch (Exception e) {
            return 2;
        } finally {
            i1 = 666;
            return i1;
        }
    }
    
    范例二
    public int doWork() {
        try {
            i1 = 1;
            if (true){
                throw new RuntimeException();
            }
            return i1;
        } catch (Exception e) {
            i1 = 777;
            return i1;
        }finally {
            i1 = 666;
            return i1;
        }
    }
    
    
```
