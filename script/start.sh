#!/bin/sh
set -e

count=`ls /usr/local/nginx/conf | wc -l`
if [[ "$count" = "0" ]];then
	echo 'the nginx conf is empty!'
	mv /mnt/conf/* /usr/local/nginx/conf/	
	rm -rf /mnt/conf
else
	rm -rf /mnt/conf
fi
exec /usr/local/nginx/sbin/nginx -g "daemon off;"
