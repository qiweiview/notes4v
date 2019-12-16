# Java中操作日期


## 获取格式化时间
```
JDK 1.8前
Date d = new Date();
SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
System.out.println("当前时间：" + sdf.format(d));

JDK 1.8后
LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
```

### 获取Date类型明天和昨天
```
 /**
     * 返回昨天
     * @param today
     * @return
     */
    public Date yesterday(Date today) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(today);
        calendar.set(Calendar.DATE, calendar.get(Calendar.DATE) - 1);
        return calendar.getTime();
    }

    /**
     * 返回明天
     * @param today
     * @return
     */
    public Date tomorrow(Date today) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(today);
        calendar.set(Calendar.DATE, calendar.get(Calendar.DATE) + 1);
        return calendar.getTime();
    }
```

## LocalDateTime转时间戳
```

//获取秒数
Long second = LocalDateTime.now().toEpochSecond(ZoneOffset.of("+8"));
//获取毫秒数
Long milliSecond = LocalDateTime.now().toInstant(ZoneOffset.of("+8")).toEpochMilli();
```

## 时间戳转LocalDateTime
```
long second = Long.parseLong(exp);
Instant instant = Instant.ofEpochSecond(second);
LocalDateTime localDateTime = LocalDateTime.ofInstant(instant,ZoneId.systemDefault());
```

## 0点和12点
```
LocalDateTime today_start = LocalDateTime.of(LocalDate.now(),LocalTime.MIN);//当天零点
LocalDateTime today_end=LocalDateTime.of(LocalDate.now(),LocalTime.MAX);//当天12点59
```

## LocalDateTime 转时间戳
```
LocalDateTime today_start = LocalDateTime.of(LocalDate.now(), LocalTime.MIN);//当天零点
LocalDateTime today_end = LocalDateTime.of(LocalDate.now(), LocalTime.MAX);//当天12点59
System.out.println(Timestamp.valueOf(today_start).getTime()/1000);
System.out.println(Timestamp.valueOf(today_end).getTime()/1000);
```

## 获取本月月初和月末
```
  LocalDate initial = LocalDate.now();
        LocalDate start = initial.withDayOfMonth(1);
        LocalDate end = initial.withDayOfMonth(initial.lengthOfMonth());
        LocalDateTime localDateTimeStart = start.atStartOfDay();
        LocalDateTime localDateTimeEnd = end.atStartOfDay();
```

## 获取本周的周一和周末
```
 LocalDate now = LocalDate.now();
        TemporalField fieldISO = WeekFields.of(Locale.PRC).dayOfWeek();
        LocalDate start = now.with(fieldISO, 1).plusDays(1);
        Integer value = now.getDayOfWeek().getValue();
        if (value==7){
            start=start.minusWeeks(1);
        }
        LocalDate end = now.with(fieldISO, 7).plusDays(1);




        LocalDateTime weekStart = start.atStartOfDay();
        LocalDateTime weekEnd = end.atStartOfDay();
//因为时区国外周末是第一天，所以要做转化
```

日期类
```
import java.time.LocalDate;
import java.time.temporal.TemporalField;
import java.time.temporal.WeekFields;
import java.util.Locale;

public class DateFactory {
    private static LocalDate dataCreateDate;//数据创建时间

    private static LocalDate startOfWeek;
    private static LocalDate endOfWeek;
    private static LocalDate startOfMonth;
    private static LocalDate endOfMonth;

    static{
        updateData();
    }


    /**
     * 确认数据是新的
     */
    private static void checkFresh() {
        LocalDate nowData = LocalDate.now();
        if (!nowData.isEqual(dataCreateDate)) {
            updateData();
        }


    }

    /**
     * 更新数据
     */
    private static void updateData() {
        /*周*/
        LocalDate now = LocalDate.now();
        int value = now.getDayOfWeek().getValue();
        TemporalField fieldISO = WeekFields.of(Locale.CHINA).dayOfWeek();
        LocalDate start = now.with(fieldISO, 1).plusDays(1);
        if (value == 7) {
            start = start.minusWeeks(1);
        }
        startOfWeek = start;
        LocalDate end = now.with(fieldISO, 7).plusDays(1);
        if (value == 7) {
            end = end.minusWeeks(1);
        }
        endOfWeek = end;

        /*月*/

        startOfMonth = now.withDayOfMonth(1);
        endOfMonth = now.withDayOfMonth(now.lengthOfMonth());

        /*完成更新*/
        dataCreateDate = LocalDate.now();

    }

    /**
     * 一周开始
     *
     * @return
     */
    public static LocalDate getStartOfWeek() {
        checkFresh();
        return startOfWeek;
    }

    /**
     * 一周结束
     *
     * @return
     */
    public static LocalDate getEndOfWeek() {
        checkFresh();
        return endOfWeek;
    }

    /**
     * 一月开始
     *
     * @return
     */
    public static LocalDate getStartOfMonth() {
        checkFresh();
        return startOfMonth;
    }

    /**
     * 一月结束
     *
     * @return
     */
    public static LocalDate getEndOfMonth() {
        checkFresh();
        return endOfMonth;
    }

}

```

## 字符串转LocalDateTime
```
 public void str2Date(){
        String startDateStr = getStartDateStr();
        DateTimeFormatter dTF = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        LocalDateTime dateTime = LocalDateTime.parse(startDateStr, dTF);
        setStartDate(dateTime);

    }
```

## 秒数转格式化时间
```
private int second = 1;
    private int minute = 60 * second;
    private int hour = 60 * minute;


    private String secondStr = "00";
    private String minuteStr = "00";
    private String hourStr = "00";


    @Test
    public void run() throws CloneNotSupportedException {



        solveTime(0*hour+20*minute+5*second);


    }


    public void solveTime(int secondNum) {
        if (secondNum < minute && secondNum >= second) {
            secondStr = addZero(secondNum);
            System.out.println(hourStr + ":" + minuteStr + ":" + secondStr);
        }

        if (secondNum < hour && secondNum >= minute) {
            int i = secondNum / minute;
            minuteStr = addZero(i);
            solveTime(secondNum % minute);
        }
        if (secondNum >= hour) {
            int i = secondNum / hour;
            hourStr = addZero(i);
            solveTime( secondNum % hour);
        }

    }

    public String addZero(int num) {
        if (num < 10) {
            return 0 + "" + num;
        } else {
            return num + "";
        }
    }
```
