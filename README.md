# Tengine Docker Images

This tengine image is based on the popular Alpine Linux project.

Tengine is a web server originated by Taobao, the largest e-commerce website in Asia. It is based on the Nginx HTTP server and has many advanced features. Tengine has proven to be very stable and efficient on some of the top 100 websites in the world, including taobao.com and tmall.com.

##启动时注意事项
启动时需要挂载conf和logs目录，比如：

```
docker run -d -p 80:80 -p 443:443 --restart=always -v /data/tengine/conf:/usr/local/nginx/conf -v /data/tengine/logs:/usr/local/nginx/logs  -v /data/ngx_oldlogs:/nginx_oldlogs -e "HOS=253" --name tengine 91ba63d98d11
```


