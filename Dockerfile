FROM nginx:alpine

ADD default.conf.tpl /etc/nginx/conf.d/default.conf.tpl

ENV DOCUMENT_ROOT /var/www/public
ENV PHP_HOST localhost
ENV PHP_PORT 9000
ENV NGINX_SENDFILE off

CMD [ \
    "sh", \
    "-c",  \
    "envsubst '${DOCUMENT_ROOT},${PHP_HOST},${PHP_PORT},${NGINX_SENDFILE}' < /etc/nginx/conf.d/default.conf.tpl > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'" \
]
