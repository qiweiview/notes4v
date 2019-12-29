# SSH转发

## 依赖
```
<dependency>
            <groupId>com.jcraft</groupId>
            <artifactId>jsch</artifactId>
            <version>0.1.55</version>
        </dependency>
```
## 实体
```
public class SSHForward {
    private String name;
    private String sshHost;
    private String sshUserName;
    private String sshUserPassword;
    private Integer sshPort;
    private Integer localBindPort;
    private Integer remoteBindPort;
```

## 监听
```
public void startPortForward() throws JSchException {
        JSch jsch = new JSch();
        //使用私钥登录
        Session session = jsch.getSession(sshForward.getSshUserName(), sshForward.getSshHost(), sshForward.getSshPort());
        session.setConfig("StrictHostKeyChecking", "no");
        //使用密码登录
        session.setPassword(sshForward.getSshUserPassword());
        session.connect(1500);
        int i = session.setPortForwardingL(sshForward.getLocalBindPort(), sshForward.getSshHost(), sshForward.getRemoteBindPort());
    }
```
