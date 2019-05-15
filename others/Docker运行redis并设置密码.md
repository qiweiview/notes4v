## Docker运行redis并设置密码
```
docker run -d  -p 6379:6379 xxxx --requirepass "mypassword"
```