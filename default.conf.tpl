
log_format log_json escape=json '{ "time": "$time_iso8601", '
 '"remote_addr": "$remote_addr", '
 '"remote_user": "$remote_user", '
 '"body_bytes_sent": "$body_bytes_sent", '
 '"response_time_s": "$request_time", '
 '"status": "$status", '
 '"request_method": "$request_method", '
 '"referrer": "$http_referer", '
 '"unique_id": "$request_id", '
 '"user_agent": "$http_user_agent", '
 '"uri": "$request_uri_path", '
 '"query": "$query_string", '
 '"x_forwarded_for": "$http_x_forwarded_for", '
 '"x_forwarded_proto": "$http_x_forwarded_proto", '
 '"host": "$host" }';

 map $request_uri $request_uri_path {
     "~^(?P<path>[^?]*)(\?.*)?$"  $path;
 }

server {
    listen 80;

    root ${DOCUMENT_ROOT};
    index  index.php;

    sendfile ${NGINX_SENDFILE};
    access_log /proc/self/fd/1 log_json;

    location / {
        try_files $uri /index.php$is_args$args;
    }

    location ~ [^/]\.php(/|$) {
        fastcgi_split_path_info ^(.+?\.php)(/.*)$;
        if (!-f $document_root$fastcgi_script_name) {
            return 404;
        }

        # Mitigate https://httpoxy.org/ vulnerabilities
        fastcgi_param HTTP_PROXY "";

        fastcgi_pass ${PHP_HOST}:${PHP_PORT};
        fastcgi_index index.php;
        fastcgi_param UNIQUE_ID $request_id;
        fastcgi_intercept_errors off;
        include /etc/nginx/fastcgi.conf;

        # to avoid php errors duplications
        error_log off;
    }
}
