# UncaughtExceptionHandler线程监控重启

```
package thread_local;

import com.java.wulin.DebugUtils;


public class TT {

    public static int count = 0;
    private Thread worker;
    private boolean init = false;
    private int restartTime = 0;

    public void init() {
        if (!init) {
            worker = new Thread(() -> {
                while (true) {
                    if (count++ > 3) {
                        throw new NullPointerException("-----count over-----");
                    }
                }
            });
            worker.setUncaughtExceptionHandler((t, e) -> {
                System.out.println("-----线程" + t.getName() + "崩了-----");
                restartTime++;
                if (restartTime < 3) {
                    count = 0;
                    init = false;
                    init();
                } else {
                    System.out.println("重启次数大于3程序关闭");
                    System.exit(1);
                }


            });
            worker.start();
            init = true;
            System.out.println(worker.getName() + "----启动-----");
        }
    }

    public static void main(String[] args) {
        TT tt = new TT();
        tt.init();
        DebugUtils.block();
    }

}

```
