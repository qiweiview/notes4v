# Java枚举

## 枚举类
```

public enum City {

    A("福州", "闽A"),
    B("莆田", "闽B"),
    C("泉州", "闽B"),
    D("厦门", "闽D");


    private String name;
    private String code;

    City(String name, String code) {
        this.name = name;
        this.code = code;
    }

    @Override
    public String toString() {
        return "GasStationChannel{" +
                "name='" + name + '\'' +
                ", code='" + code + '\'' +
                '}';
    }

    public static void main(String[] args) {
        System.out.println(City.A);
    }

}
```

## 内部类
```
public class TestEnum {

    enum BZZ{
        
        cc("cc"),
        dd("dd"),
        ee("ee");

        private String name;

        BZZ(String name) {
            this.name = name;
        }
    }

}
```
