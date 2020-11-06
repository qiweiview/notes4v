# GroupUtils分组工具
```
import java.util.*;

public class GroupUtils {

    public static <T> Map<String, List<T>> groupList(List<T> list, InnerValueGetter<T> innerValueGetter) {
        if (list == null || list.size() < 1) {
            return new HashMap<>();
        }
        Map<String, List<T>> map = new HashMap<>();
        Iterator<T> iterator = list.iterator();
        while (iterator.hasNext()) {
            T next = iterator.next();
            String value = innerValueGetter.getValue(next);
            List<T> ts = map.get(value);
            if (ts == null) {
                ts = new ArrayList<>();
                map.put(value, ts);
            }
            ts.add(next);
        }

        return map;
    }

    public interface InnerValueGetter<T> {
        public String getValue(T t);
    }
}

```
