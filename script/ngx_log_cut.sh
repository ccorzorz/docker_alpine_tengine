#!/bin/sh
set -x
logs_path="/usr/local/nginx/logs"
oldlogs_path="/nginx_oldlogs/"

for i in `ls $logs_path/* |grep -v nginx.pid |grep -v oldlogs`
        do
        mv "$i"  "$i"_${HOS}_$(date -d "yesterday" +"%Y%m%d")
        mv "$i"_${HOS}_$(date -d "yesterday" +"%Y%m%d")  $oldlogs_path
done

#向nginx主进程发信号重新打开日志
nginx_pid= `ps -ef |grep nginx|grep master|awk '{print $1}'`
kill -USR1 $nginx_pid
/usr/local/nginx/sbin/nginx -t && /usr/local/nginx/sbin/nginx -s reload

sleep 2
#docker exec -it tengine  /usr/local/nginx/sbin/nginx -s reopen

#sleep 1 

#clear the expired logs
cd $oldlogs_path
#find ./ -mtime +90 -exec rm -rf {} \;
echo "The old logfiles is deleted!!"

