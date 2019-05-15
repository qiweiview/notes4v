第1步：更新系统
使用以下命令将Ubuntu 16.04系统更新到最新的稳定状态：
sudo apt-get update


第2步：安装Erlang
由于RabbitMQ是用Erlang编写的，因此在使用RabbitMQ之前需要先安装Erlang：
sudo apt-get install erlang-nox

验证您的Erlang安装：
erl

您将被带入Erlang shell，它类似于：
Erlang/OTP 20 [erts-9.1] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:10] [hipe] [kernel-poll:false]

Eshell V9.1  (abort with ^G)

按Ctrl+C两次退出Erlang shell。

第3步：安装RabbitMQ

安装rabbitmq-server包：
sudo apt-get install rabbitmq-server


第4步：启动服务器
sudo systemctl start rabbitmq-server.service
sudo systemctl enable rabbitmq-server.service

你可以检查RabbitMQ的状态：
sudo rabbitmqctl status

默认情况下，RabbitMQ创建一个名为“ guest” 的用户，密码为“ guest”。您还可以使用以下命令在RabbitMQ服务器上创建自己的管理员帐户。更改password为您自己的密码。
sudo rabbitmqctl add_user admin password 
sudo rabbitmqctl set_user_tags admin administrator
sudo rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"


步骤5：启用并使用RabbitMQ管理控制台
启用RabbitMQ管理控制台，以便您可以从Web浏览器监控Rab​​bitMQ服务器进程：
sudo rabbitmq-plugins enable rabbitmq_management
sudo chown -R rabbitmq:rabbitmq /var/lib/rabbitmq/

接下来，您需要设置管理员用户帐户以访问RabbitMQ服务器管理控制台。在以下命令中，“ mqadmin”是管理员的用户名，“ mqadminpassword”是密码。记得用自己的替换它们。
sudo rabbitmqctl add_user mqadmin mqadminpassword
sudo rabbitmqctl set_user_tags mqadmin administrator
sudo rabbitmqctl set_permissions -p / mqadmin ".*" ".*" ".*"

现在，访问以下URL：
http://[your-vultr-server-IP]:15672/