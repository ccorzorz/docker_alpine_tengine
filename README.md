# Tengine Docker Images

This tengine image is based on the popular Alpine Linux project.

Tengine is a web server originated by Taobao, the largest e-commerce website in Asia. It is based on the Nginx HTTP server and has many advanced features. Tengine has proven to be very stable and efficient on some of the top 100 websites in the world, including taobao.com and tmall.com.

##启动时注意事项
启动时需要挂载conf和logs目录，增加了nginx自动切割日志脚本，并且目录挂载到容器内部的/nginx_oldlogs目录,支持hos参数，hos参数将在日志切割时使用，运行命令如下:

```
docker run -d -p 80:80 -p 443:443 --restart=always -v /data/tengine/conf:/usr/local/nginx/conf -v /data/tengine/logs:/usr/local/nginx/logs  -v /data/ngx_oldlogs:/nginx_oldlogs -e "HOS=253" --name tengine 91ba63d98d11
```


