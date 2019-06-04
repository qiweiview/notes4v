
## 给定一个整数数组 nums 和一个目标值 target，请你在该数组中找出和为目标值的那 两个 整数，并返回他们的数组下标。

示例:

给定 nums = [2, 7, 11, 15], target = 9

因为 nums[0] + nums[1] = 2 + 7 = 9
所以返回 [0, 1]

解法
```
 public int[] twoSum(int[] nums, int target) {


        if (nums.length == 2) {
            return new int[]{0, 1};
        }


        Map<Integer, Integer> expect = new HashMap();


        for (int i = 0; i < nums.length; i++) {
            if (i != 0) {
                Integer integer = expect.get(target - nums[i]);
                if (integer != null) {
                    return new int[]{integer, i};
                }
                expect.put(nums[i], i);
            }

            expect.put(nums[i], i);


        }
        return null;

    }
```

1. 特殊情况两位直接return [0,1]
2. hash符合的直接return 复杂度O（1）
