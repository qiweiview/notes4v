## Java中break和continue:

###示例代码：
```
for(int i=0;i<5;i++){
            if(i==2){
                System.out.println("i==2时忽略了");
                continue;//忽略i==2时的循环
            }
            System.out.println("当前i的值为"+i);
        }
        
        for(int i =0;i<5;i++){
            System.out.println("当前i的值"+i);
            if(i==2){
                return;  //直接结束main()方法
            }
        }
        
        for(int i =0;i<5;i++){
            System.out.println("当前i的值"+i);
            if(i==2){
                break;  //直接结束for循环
            }
        }
        
        
        bgm:for(int i=0;i<2;i++){
                for(int j=0;j<4;j++){
                    System.out.println("当前i的值"+j);
                    if(j==2){
                        System.out.println("当前j的值="+j);
                        break bgm;//跳出外循环，给外循环起一个名字，然后使用break 名字  跳出外循环
                    }
                }
        }
```