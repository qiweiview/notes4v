
## 注册为组件在构造方法注入，用类名.属性赋值
```
@Component
public class MailUtils {

	private static Environment env;
	private static String HOST;
	private static Integer PORT;
	private static String USERNAME;
	private static String PASSWORD;
	private static String EMAILFORM;
	private static JavaMailSenderImpl mailSender;

	@Autowired
	public MailUtils(Environment env) {
		MailUtils.env = env;
		MailUtils.HOST = env.getProperty("mail.maihost");
		MailUtils.PORT = Integer.parseInt(env.getProperty("mail.maiport"));
		MailUtils.USERNAME = env.getProperty("mail.mailName");
		MailUtils.PASSWORD = env.getProperty("mail.maipassword");
		MailUtils.EMAILFORM = env.getProperty("mail.maisendName");
		MailUtils.mailSender= createMailSender();
	}
}
```