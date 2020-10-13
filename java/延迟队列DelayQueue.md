# 延迟队列DelayQueue


## 范例

```

import com.google.common.primitives.Ints;
import java.util.concurrent.DelayQueue;
import java.util.concurrent.Delayed;
import java.util.concurrent.TimeUnit;

public class DelayTest {
    public static void main(String[] args) throws InterruptedException {
        DelayQueue delayQueue = new DelayQueue<DelayObject>();
        delayQueue.add(new DelayObject("apple", 3 * 1000));
        DelayObject take2 = (DelayObject) delayQueue.take();
        take2.work();
    }

    public static class DelayObject implements Delayed {
        private String data;
        private long startTime;

        public void work() {
            System.out.println("i take the:" + data);
        }

        public DelayObject(String data, long delayInMilliseconds) {
            this.data = data;
            this.startTime = System.currentTimeMillis() + delayInMilliseconds;
        }

        @Override
        public long getDelay(TimeUnit unit) {
            long diff = startTime - System.currentTimeMillis();
            return unit.convert(diff, TimeUnit.MILLISECONDS);
        }

        @Override
        public int compareTo(Delayed o) {
            return Ints.saturatedCast(this.startTime - ((DelayObject) o).startTime);
        }
    }
}
```
