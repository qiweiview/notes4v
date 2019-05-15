## 给定一个数组 nums，编写一个函数将所有 0 移动到数组的末尾，同时保持非零元素的相对顺序

### 示例:
输入: [0,1,0,3,12]
输出: [1,3,12,0,0]

### 说明:
必须在原数组上操作，不能拷贝额外的数组。
尽量减少操作次数。


解法
```
 public void moveZeroes(int[] nums) {
        
        if(nums.length==1){
            return;
        }
      
        int nozero_point=0;
       
        
        for(int i=0;i<nums.length;i++){
            if(nums[i]!=0){
                nums[nozero_point]=nums[i];
                nozero_point++;
            }
        }
        for(int j=nums.length-1;j>nozero_point-1;j--){
            nums[j]=0; 
        }
        
        
    }
```

1. 判断特殊情况，1位直接return
2. 从第一位开始找非0的值，通过nozero_point（初始值0）的移动，从数组头开始塞值
2. 通过nozero_point塞了几个非0数，确定末尾剩余几位，将他们都置0，