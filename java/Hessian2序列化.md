# Hessian2序列化

* 工具
```

import com.alibaba.com.caucho.hessian.io.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * Created by lbzhao on 2016/12/12.
 */
public class HessianSerialization {

    private final static Logger logger = LoggerFactory.getLogger(HessianSerialization.class);
    private static SerializerFactory serializerFactory = new SerializerFactory();

    public static void main(String[] args) throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();

        String name="hello";
        byteArrayOutputStream.write(serialize(name));
        Integer age=18;
        byteArrayOutputStream.write(serialize(age));
        HashMap hashMap=new HashMap();
        hashMap.put("address","xm");
        byteArrayOutputStream.write(serialize(hashMap));
        List<Object> deserialize = deserialize(byteArrayOutputStream.toByteArray());
        deserialize.forEach(x->{
            System.out.println(x.getClass()+"--->"+x);
        });



    }


    /**
     * hessian serialize
     * @param obj java object
     * @return byte array
     */
    public static byte[] serialize(Object obj) {
        ByteArrayOutputStream os = new ByteArrayOutputStream();
        AbstractHessianOutput out = new Hessian2Output(os);

        out.setSerializerFactory(serializerFactory);
        try {
            out.writeObject(obj);
            out.close();
        } catch (Exception e) {
            logger.error("hessian serialize failed," + e);
        }
        return os.toByteArray();
    }

    /**
     * hessian deserialize
     * @param bytes byte array
     * @return java object
     */
    public static  List<Object> deserialize(byte[] bytes) {
        List<Object> list=new ArrayList<>();
        ByteArrayInputStream is = new ByteArrayInputStream(bytes);
        AbstractHessianInput in = new Hessian2Input(is);


        in.setSerializerFactory(serializerFactory);
        Object value = null;
        try {
            while ((value = in.readObject())!=null){
                list.add(value);
            }
            in.close();
        } catch (IOException e) {
           e.printStackTrace();
        }
        return list;
    }
}
```
