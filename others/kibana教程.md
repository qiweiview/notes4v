# kibana教程

## Nignx反向代理到kibana

* nginx.conf
```
location /kibana {
rewrite ^/kibana/(.*)$ /$1 break;
proxy_pass http://localhost:5601/;
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection 'upgrade';
proxy_set_header Host $host;
proxy_cache_bypass $http_upgrade;
}
```

* kibana.yml
```
server.basePath: "/kibana"
server.rewriteBasePath: false
```
