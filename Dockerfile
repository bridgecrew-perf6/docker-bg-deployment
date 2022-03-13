FROM ubuntu:20.04

ENV NGINX_VERSION=1.21.6

ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update -q
RUN apt install -y -q golang \
                      git \
                      build-essential \
                      libpcre3-dev \
                      zlib1g-dev \
                      libssl-dev \
                      tzdata

ENV GOPATH=/go
ENV PATH=/nginx/sbin:/go/bin:$PATH
RUN go env -w GO111MODULE=on
RUN go get github.com/cubicdaiya/nginx-build@latest
RUN git clone https://github.com/cubicdaiya/ngx_dynamic_upstream.git /usr/local/src/ngx_dynamic_upstream

RUN nginx-build \
    -d work \
    -v ${NGINX_VERSION} \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-compat \
    --with-file-aio \
    --with-threads \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-cc-opt='-g -O2 -ffile-prefix-map=/data/builder/debuild/nginx-1.21.6/debian/debuild-base/nginx-1.21.6=. -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' \
    --with-ld-opt='-Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie' \
    --add-module=/usr/local/src/ngx_dynamic_upstream
RUN cd work/nginx/${NGINX_VERSION}/nginx-${NGINX_VERSION} && make install

RUN useradd -r nginx
RUN install -o nginx -d /var/cache/nginx/client_temp
RUN install -o nginx -d /var/cache/nginx/proxy_temp
RUN install -o nginx -d /var/cache/nginx/fastcgi_temp
RUN install -o nginx -d /var/cache/nginx/uwsgi_temp
RUN install -o nginx -d /var/cache/nginx/scgi_temp

COPY nginx/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
