server {
    listen 80;

    root ${DOCUMENT_ROOT};
    index  index.php;

    sendfile ${NGINX_SENDFILE};

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
