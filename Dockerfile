FROM alpine:3.7
# alpine:latest

MAINTAINER Shane.Cheng ccniubi@163.com ( http://github.com/ccorzorz/ )

ENV TENGINE_VERSION 2.2.2

# nginx: https://git.io/vSIyj


ENV CONFIG "\
	--prefix=/usr/local/nginx \
	--pid-path=/var/run/nginx.pid \
	--lock-path=/var/run/nginx.lock \
	--user=nginx \
	--group=nginx \
	--with-http_ssl_module \
	--with-http_realip_module \
	--with-http_addition_module \
	--with-http_sub_module \
	--with-http_dav_module \
	--with-http_flv_module \
	--with-http_mp4_module \
	--with-http_gunzip_module \
	--with-http_gzip_static_module \
	--with-http_random_index_module \
	--with-http_secure_link_module \
	--with-http_stub_status_module \
	--with-http_auth_request_module \
	--with-http_xslt_module=shared \
	--with-http_image_filter_module=shared \
	--with-http_geoip_module=shared \
	--with-threads \
	--with-http_slice_module \
	--with-mail \
	--with-mail_ssl_module \
	--with-file-aio \
	--with-http_v2_module \
	--with-http_concat_module \
	--with-http_sysguard_module \
	--with-http_dyups_module \
	"

# Modify respository and localtime of alpine
RUN  sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories && \ 
     apk update && \
     apk add tzdata && \
     ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
     echo "Asia/Shanghai" > /etc/timezone


RUN addgroup -S nginx \
	&& adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
	&& apk add --no-cache --virtual .build-deps \
		gcc \
		libc-dev \
		make \
		openssl-dev \
		pcre-dev \
		zlib-dev \
		linux-headers \
		curl \
		gnupg \
		libxslt-dev \
		gd-dev \
		geoip-dev;
RUN curl -L "http://tengine.taobao.org/download/tengine-$TENGINE_VERSION.tar.gz" -o tengine.tar.gz \
	&& mkdir -p /usr/src \
  && tar -zxC /usr/src -f tengine.tar.gz \
  && rm tengine.tar.gz \
  && cd /usr/src/tengine-$TENGINE_VERSION/ \
	&& ./configure $CONFIG \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	&& mkdir /usr/local/nginx/conf/vhost/ \
#	&& mkdir -p /usr/local/nginx/logs \
	&& mkdir -p /website/html \
        && install -m644 html/index.html /website/html/ \
        && install -m644 html/50x.html /website/html/ \
	&& strip /usr/local/nginx/sbin/nginx* \
	&& strip /usr/local/nginx/modules/*.so \
	&& rm -rf /usr/src/tengine-$TENGINE_VERSION \
	\
	# Bring in gettext so we can get `envsubst`, then throw
	# the rest away. To do this, we need to install `gettext`
	# then move `envsubst` out of the way so `gettext` can
	# be deleted completely, then move `envsubst` back.
	&& apk add --no-cache --virtual .gettext gettext \
	&& mv /usr/bin/envsubst /tmp/ \
	\
	&& runDeps="$( \
		scanelf --needed --nobanner /usr/local/nginx/sbin/nginx /usr/local/nginx/modules/*.so /tmp/envsubst \
			| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
			| sort -u \
			| xargs -r apk info --installed \
			| sort -u \
	)" \
	&& apk add --no-cache --virtual .nginx-rundeps $runDeps \
	&& apk del .build-deps \
	&& apk del .gettext \
	&& mv /tmp/envsubst /usr/local/bin/ \
        && mv /usr/local/nginx/conf /mnt/ 
#	\
	# forward request and error logs to docker log collector
#	&& ln -sf /dev/stdout /usr/local/nginx/logs/access.log \
#	&& ln -sf /dev/stderr /usr/local/nginx/logs/error.log


COPY nginx.conf /mnt/conf/nginx.conf
COPY proxy_params /mnt/conf/proxy_params
COPY nginx.vh.default.conf /mnt/conf/vhost/default.conf
COPY example /mnt/conf/vhost/example
COPY script /script
RUN chmod +x /script/start.sh


VOLUME ["/usr/local/nginx/logs","/usr/local/nginx/conf"]

EXPOSE 80 443

#CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
CMD ["/script/start.sh"]
