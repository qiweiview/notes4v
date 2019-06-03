## Java中break和continue:

### 示例代码：
#### continue
```
for(int i=0;i<5;i++){
            if(i==2){
                System.out.println("i==2时忽略了");
                continue;//忽略i==2时的循环
            }
            System.out.println("当前i的值为"+i);
        }
```
#### return
```
        for(int i =0;i<5;i++){
            System.out.println("当前i的值"+i);
            if(i==2){
                return;  //直接结束main()方法
            }
        }
```
#### break
```
        for(int i =0;i<5;i++){
            System.out.println("当前i的值"+i);
            if(i==2){
                break;  //直接结束for循环
            }
        }
```

### break label 语法使用

#### break 
```
 for (int i = 0; i < 3; i++) {
            int j = 0;
            System.out.println("=================>"+i);
            while (true) {
                System.out.println("**********》"+j);
                if (j == 2) {
                    break;
                } else {
                    j++;
                }
            }
        }
```

打印
```
=================>0
**********》0
**********》1
**********》2
=================>1
**********》0
**********》1
**********》2
=================>2
**********》0
**********》1
**********》2
```

#### break label
```
 view:
        for (int i = 0; i < 3; i++) {
            int j = 0;
            System.out.println("label=================>"+i);
            while (true) {
                System.out.println("label**********》"+j);
                if (j == 2) {

                    break view;
                } else {
                    j++;
                }
            }
        }
```

打印
```
label=================>0
label**********》0
label**********》1
label**********》2
```


#### continue 
```
  for (int i = 0; i < 3; i++) {
            System.out.println("=================>"+i);
            for(int k = 0;k<3;k++){
                if(k==1) continue;
                System.out.println("*********>"+k);
            }
        }
```

打印
```
=================>0
*********>0
*********>2
=================>1
*********>0
*********>2
=================>2
*********>0
*********>2
```


#### continue label
```
view:
        for (int i = 0; i < 3; i++) {
            System.out.println("label=================>"+i);
            for(int k = 0;k<3;k++){
                if(k==1) continue view;
                System.out.println("label*********>"+k);
            }
        }
```

打印
```
label=================>0
label*********>0
label=================>1
label*********>0
label=================>2
label*********>0

```
