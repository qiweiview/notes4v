# Lua教程

## if
```
score = 90
if score == 100 then
    print("Very good!Your score is 100")
elseif score >= 60 then
    print("Congratulations, you have passed it,your score greater or equal to 60")
--此处可以添加多个elseif
else
    print("Sorry, you do not pass the exam! ")
end
```

## while
```
i=1
while i<50 do
print(i)
i=i+1
end
```

## repeat
```
x = 10
repeat
    print(x)
	x=x-1
	
until x==3
```

## for
* 起始，终止，步长
```
for i = 10, 1, -1 do
  print(i)
end
```

## 函数
```
local hi=function(arc)  
print('im good',arc)
end

function hi2(arc)  
print('im good 2',arc)
end

hi('view')
```

### 值传递
```
local function swap(a, b) 
   local temp = a
   a = b
   b = temp
   print(a, b)
end

local x = "hello"
local y = 20
print(x, y)
swap(x, y)    
print(x, y)  

-->output
hello 20
20  hello
hello 20
```

### 变长参数
```
local function func( ... )                -- 形参为 ... ,表示函数采用变长参数
   local temp = {...}                     -- 访问的时候也要使用 ...
   local length=table.getn(temp)
   print(length)
end

func(1,2,3)
```

## 文件IO
* 读文件
```
file = io.input("test1.txt")    -- 使用 io.input() 函数打开文件

repeat
    line = io.read()            -- 逐行读取内容，文件结束时返回nil
    if nil == line then
        break
    end
    print(line)
until (false)

io.close(file)                  -- 关闭文件
```

* 写文件
```
file = io.open("test1.txt", "a+")   -- 使用 io.open() 函数，以添加模式打开文件
io.output(file)                     -- 使用 io.output() 函数，设置默认输出文件
io.write("\nhello world")           -- 使用 io.write() 函数，把内容写到文件
io.close(file)
```
