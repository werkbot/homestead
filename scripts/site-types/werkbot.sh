#!/usr/bin/env bash

declare -A params=$6       # Create an associative array
declare -A headers=${9}    # Create an associative array
declare -A rewrites=${10}  # Create an associative array



# NGINX Config
paramsTXT=""
if [ -n "$6" ]; then
   for element in "${!params[@]}"
   do
      paramsTXT="${paramsTXT}
      fastcgi_param ${element} ${params[$element]};"
   done
fi
headersTXT=""
if [ -n "${9}" ]; then
   for element in "${!headers[@]}"
   do
      headersTXT="${headersTXT}
      add_header ${element} ${headers[$element]};"
   done
fi
rewritesTXT=""
if [ -n "${10}" ]; then
   for element in "${!rewrites[@]}"
   do
      rewritesTXT="${rewritesTXT}
      location ~ ${element} { if (!-f \$request_filename) { return 301 ${rewrites[$element]}; } }"
   done
fi

if [ "$7" = "true" ]
then configureXhgui="
location /xhgui {
        try_files \$uri \$uri/ /xhgui/index.php?\$args;
}
"
else configureXhgui=""
fi

block="server {
    listen ${3:-80};
    listen ${4:-443} ssl http2;
    server_name .$1;
    root \"$2\";

    index index.html index.htm index.php;

    charset utf-8;

    $rewritesTXT

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
        $headersTXT
    }

    $configureXhgui

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/$1-error.log error;

    sendfile off;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php$5-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        $paramsTXT

        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }

    ssl_certificate     /etc/ssl/certs/$1.crt;
    ssl_certificate_key /etc/ssl/certs/$1.key;
}
"

echo "$block" > "/etc/nginx/sites-available/$1"
ln -fs "/etc/nginx/sites-available/$1" "/etc/nginx/sites-enabled/$1"



# Apache Config
paramsTXT=""
if [ -n "$6" ]; then
    for element in "${!params[@]}"
    do
        paramsTXT="${paramsTXT}
        SetEnv ${element} \"${params[$element]}\""
    done
fi
headersTXT=""
if [ -n "${9}" ]; then
   for element in "${!headers[@]}"
   do
      headersTXT="${headersTXT}
      Header always set ${element} \"${headers[$element]}\""
   done
fi

export DEBIAN_FRONTEND=noninteractive

block="<VirtualHost *:$3>
    ServerAdmin webmaster@localhost
    ServerName $1
    ServerAlias www.$1
    DocumentRoot "$2"
    $paramsTXT
    $headersTXT

    <Directory "$2">
        AllowOverride All
        Require all granted
        EnableMMAP Off
    </Directory>
    <IfModule mod_fastcgi.c>
        AddHandler php"$5"-fcgi .php
        Action php"$5"-fcgi /php"$5"-fcgi
        Alias /php"$5"-fcgi /usr/lib/cgi-bin/php"$5"
        FastCgiExternalServer /usr/lib/cgi-bin/php"$5" -socket /var/run/php/php"$5"-fpm.sock -pass-header Authorization
    </IfModule>
    <IfModule !mod_fastcgi.c>
        <IfModule mod_proxy_fcgi.c>
            <FilesMatch \".+\.ph(ar|p|tml)$\">
                SetHandler \"proxy:unix:/var/run/php/php"$5"-fpm.sock|fcgi://localhost\"
            </FilesMatch>
        </IfModule>
    </IfModule>
    #LogLevel info ssl:warn

    ErrorLog \${APACHE_LOG_DIR}/$1-error.log
    CustomLog \${APACHE_LOG_DIR}/$1-access.log combined

    #Include conf-available/serve-cgi-bin.conf
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
"

echo "$block" > "/etc/apache2/sites-available/$1.conf"
ln -fs "/etc/apache2/sites-available/$1.conf" "/etc/apache2/sites-enabled/$1.conf"

blockssl="<IfModule mod_ssl.c>
    <VirtualHost *:$4>

        ServerAdmin webmaster@localhost
        ServerName $1
        ServerAlias www.$1
        DocumentRoot "$2"
        $paramsTXT

        <Directory "$2">
            AllowOverride All
            Require all granted
        </Directory>

        #LogLevel info ssl:warn

        ErrorLog \${APACHE_LOG_DIR}/$1-error.log
        CustomLog \${APACHE_LOG_DIR}/$1-access.log combined

        #Include conf-available/serve-cgi-bin.conf

        #   SSL Engine Switch:
        #   Enable/Disable SSL for this virtual host.
        SSLEngine on

        #SSLCertificateFile  /etc/ssl/certs/ssl-cert-snakeoil.pem
        #SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key

        SSLCertificateFile      /etc/ssl/certs/$1.crt
        SSLCertificateKeyFile   /etc/ssl/certs/$1.key


        #SSLCertificateChainFile /etc/apache2/ssl.crt/server-ca.crt

        #SSLCACertificatePath /etc/ssl/certs/
        #SSLCACertificateFile /etc/apache2/ssl.crt/ca-bundle.crt

        #SSLCARevocationPath /etc/apache2/ssl.crl/
        #SSLCARevocationFile /etc/apache2/ssl.crl/ca-bundle.crl

        #SSLVerifyClient require
        #SSLVerifyDepth  10

        <FilesMatch \"\.(cgi|shtml|phtml|php)$\">
            SSLOptions +StdEnvVars
        </FilesMatch>
        <Directory /usr/lib/cgi-bin>
            SSLOptions +StdEnvVars
        </Directory>

        <IfModule mod_fastcgi.c>
            AddHandler php"$5"-fcgi .php
            Action php"$5"-fcgi /php"$5"-fcgi
            Alias /php"$5"-fcgi /usr/lib/cgi-bin/php"$5"
            FastCgiExternalServer /usr/lib/cgi-bin/php"$5" -socket /var/run/php/php"$5"-fpm.sock -pass-header Authorization
        </IfModule>
        <IfModule !mod_fastcgi.c>
            <IfModule mod_proxy_fcgi.c>
                <FilesMatch \".+\.ph(ar|p|tml)$\">
                    SetHandler \"proxy:unix:/var/run/php/php"$5"-fpm.sock|fcgi://localhost\"
                </FilesMatch>
            </IfModule>
        </IfModule>
        BrowserMatch \"MSIE [2-6]\" \
            nokeepalive ssl-unclean-shutdown \
            downgrade-1.0 force-response-1.0
        # MSIE 7 and newer should be able to use keepalive
        BrowserMatch \"MSIE [17-9]\" ssl-unclean-shutdown

    </VirtualHost>
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
"

echo "$blockssl" > "/etc/apache2/sites-available/$1-ssl.conf"
ln -fs "/etc/apache2/sites-available/$1-ssl.conf" "/etc/apache2/sites-enabled/$1-ssl.conf"
