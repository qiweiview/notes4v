# ASM教程

## 操作属性
* 新增属性
* 删除属性
* 修改方法
* 删除方法
```
package core.asm2;

import org.objectweb.asm.ClassVisitor;
import org.objectweb.asm.FieldVisitor;
import org.objectweb.asm.MethodVisitor;
import org.objectweb.asm.Opcodes;


import java.util.HashSet;

public class MyClassAdapter extends ClassVisitor {
    HashSet<String> fileSet = new HashSet<>();

    public MyClassAdapter(ClassVisitor cv) {
        super(Opcodes.ASM8, cv);
    }

    @Override
    public MethodVisitor visitMethod(int access, String name, String descriptor, String signature, String[] exceptions) {
        if ("swim".equals(name)) {
            return super.visitMethod(access, name + "AndDrink", descriptor, signature, exceptions);
        }
         if (name.equals("delMethod")){
            return null;
        }
        return super.visitMethod(access, name, descriptor, signature, exceptions);
    }


    @Override
    public FieldVisitor visitField(int access, String name, String descriptor, String signature, Object value) {
        if (name.equals("delField") && descriptor.equals("()V")) {
            //todo：不要委托至下一个访问器 -> 这样将移除该方法
            return null;
        }
        fileSet.add(name);
        return super.visitField(access, name, descriptor, signature, value);
    }

    @Override
    public void visitEnd() {
        if (!fileSet.contains("newSkill")) {
            //todo 避免重复添加属性
            FieldVisitor fieldVisitor = visitField(Opcodes.ACC_PUBLIC, "newSkill", "Ljava/lang/String;", null, "run");
            if (fieldVisitor != null) {
                fieldVisitor.visitEnd();
            }
        }
        super.visitEnd();
    }

}

```

## 操作方法
* 新增get/set方法
```
  ClassWriter cw = new ClassWriter(ClassWriter.COMPUTE_MAXS);
        ClassReader cr = new ClassReader("core.asm_lombok.SystemUser");
        cr.accept(cw, 0);

        //add getMethod
        MethodVisitor methodVisitor = cw.visitMethod(Opcodes.ACC_PUBLIC, "getName", "()Ljava/lang/String;", null, null);
        methodVisitor.visitCode();
        Label label0 = new Label();
        methodVisitor.visitLabel(label0);
        methodVisitor.visitVarInsn(Opcodes.ALOAD, 0);
        methodVisitor.visitFieldInsn(Opcodes.GETFIELD, "core/asm_lombok/SystemUser", "name", "Ljava/lang/String;");
        methodVisitor.visitInsn(Opcodes.ARETURN);
        methodVisitor.visitMaxs(1, 1);
        methodVisitor.visitEnd();

        //add setMethod
        methodVisitor = cw.visitMethod(Opcodes.ACC_PUBLIC, "setName", "(Ljava/lang/String;)V", null, null);
        methodVisitor.visitCode();
        Label label0_t = new Label();
        methodVisitor.visitLabel(label0_t);

        methodVisitor.visitVarInsn(Opcodes.ALOAD, 0);
        methodVisitor.visitVarInsn(Opcodes.ALOAD, 1);
        methodVisitor.visitFieldInsn(Opcodes.PUTFIELD, "core/asm_lombok/SystemUser", "name", "Ljava/lang/String;");
        Label label1_t = new Label();
        methodVisitor.visitLabel(label1_t);
        methodVisitor.visitInsn(Opcodes.RETURN);
        methodVisitor.visitMaxs(2, 2);
        methodVisitor.visitEnd();

        byte[] bytes = cw.toByteArray();
        MyClassLoader myClassLoader = new MyClassLoader();
        Class aClass = myClassLoader.defineClass("core.asm_lombok.SystemUser", bytes);
        Constructor constructor = aClass.getConstructor(null);
        Object o = constructor.newInstance(null);
        Method[] declaredMethods = aClass.getDeclaredMethods();
        Stream.of(declaredMethods).forEach(x->{
            System.out.println(x);
        });

        System.out.println(o);
```






