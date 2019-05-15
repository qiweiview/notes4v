## 1.js操作日期


```
//时间戳转日期
var timestamp=new Date(parseInt(insertresult.wiParkRecord.pakrec_entertime));
timestamp.toLocaleString()

//Js字符串转日期：
//2018-04-27 03:03:00
var d = new Date(Date.parse(value.replace(/-/g,   "/"))).getTime();

//计算日期相差小时：
var resultDates=parseInt(Math.abs(date2-date1)/1000/60/60);


```


------------------------------
### 拓展：
```
vue.js
时间戳转日期
formatDate:function(value){
			const date=new Date(value);
			Y=date.getFullYear(),
			m=date.getMonth()+1,
			d=date.getDate(),
			H=date.getHours(),
			i=date.getMinutes(),
			s=date.getSeconds();
			if(m<10){m='0'+m;}
			if(d<10){d='0'+d;}
			if(H<10){H='0'+H;}
			if(i<10){i='0'+i;}
			if(s<10){s='0'+s;}
			const t=Y+"-"+m+"-"+d+' '+H+":"+i+":"+s;
			return t;
		}1

调用：
(这里是俩中括号^-^)formatDate(xxx)}}

```
