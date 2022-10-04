#!/bin/sh

# If you would like to do some extra provisioning you may
# add any commands you wish to this file and they will
# be run after the Homestead machine is provisioned.
#
# If you have user-specific configurations you would like
# to apply, you may also create user-customizations.sh,
# which will be run after this script.



# Check if phpmyadmin Has Been Installed
if [ -f /home/vagrant/.homestead-features/phpmyadmin ]
then
    echo "phpmyadmin already installed."
else
touch /home/vagrant/.homestead-features/phpmyadmin
chown -Rf vagrant:vagrant /home/vagrant/.homestead-features

LATEST_VERSION=$(curl -sS 'https://api.github.com/repos/phpmyadmin/phpmyadmin/releases/latest' | awk -F '"' '/tag_name/{print $4}')
DOWNLOAD_URL="https://api.github.com/repos/phpmyadmin/phpmyadmin/tarball/$LATEST_VERSION"

echo "Downloading phpMyAdmin $LATEST_VERSION"
wget $DOWNLOAD_URL -q --show-progress -O 'phpmyadmin.tar.gz'

mkdir phpmyadmin && tar xf phpmyadmin.tar.gz -C phpmyadmin --strip-components 1

rm phpmyadmin.tar.gz

CMD=/vagrant/scripts/site-types/laravel.sh
CMD_CERT=/vagrant/scripts/create-certificate.sh

if [ ! -f $CMD ]; then
    # Fallback for older Homestead versions
    CMD=/vagrant/scripts/serve.sh
else
    # Create an SSL certificate
    # sudo bash $CMD_CERT phpmyadmin.local
    echo "SSL certificate skipped"
fi

sudo bash $CMD phpmyadmin.local $(pwd)/phpmyadmin 80 443 7.3

echo "Installing dependencies for phpMyAdmin"
cd phpmyadmin && composer update --no-dev && yarn

sudo service nginx reload
fi
# End phpmyadmin



# Check if Google Chrome Has Been Installed
if [ -f /home/vagrant/.homestead-features/google-chrome ]
then
    echo "Google Chrome already installed."
else
	touch /home/vagrant/.homestead-features/google-chrome
	chown -Rf vagrant:vagrant /home/vagrant/.homestead-features

	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	sudo apt-get update
	sudo apt install ./google-chrome-stable_current_amd64.deb
	rm google-chrome-stable_current_amd64.deb
fi
# End Google Chrome



# Check if PHP has been configured
if [ -f /home/vagrant/.homestead-features/php ]
then
    echo "PHP already configured."
else
	# PHP 7.3
	touch /home/vagrant/.homestead-features/php
	sudo chmod 777 /etc/php/7.3/fpm/php.ini
	PHP_INI=$(cat /etc/php/7.3/fpm/php.ini)
	PHP_INI=$(echo "$PHP_INI" | sed 's/upload_max_filesize =.*/upload_max_filesize = 0/')
	PHP_INI=$(echo "$PHP_INI" | sed 's/post_max_size =.*/post_max_size = 0/')
	PHP_INI=$(echo "$PHP_INI" | sed 's/max_execution_time =.*/max_execution_time = 0/')
	PHP_INI=$(echo "$PHP_INI" | sed 's/max_input_time =.*/max_input_time = 0/')
	# sendmail config
	PHP_INI=$(echo "$PHP_INI" | sed 's/;mail.force_extra_parameters =.*/mail.force_extra_parameters = "-f %s"/')
	PHP_INI=$(echo "$PHP_INI" | sed 's/mail.add_x_header = Off/mail.add_x_header = On/')
	sudo echo "$PHP_INI" > /etc/php/7.3/fpm/php.ini
	sudo service php7.3-fpm restart

	# PHP 7.4
	touch /home/vagrant/.homestead-features/php
	sudo chmod 777 /etc/php/7.4/fpm/php.ini
	PHP_INI=$(cat /etc/php/7.4/fpm/php.ini)
	PHP_INI=$(echo "$PHP_INI" | sed 's/upload_max_filesize =.*/upload_max_filesize = 0/')
	PHP_INI=$(echo "$PHP_INI" | sed 's/post_max_size =.*/post_max_size = 0/')
	PHP_INI=$(echo "$PHP_INI" | sed 's/max_execution_time =.*/max_execution_time = 0/')
	PHP_INI=$(echo "$PHP_INI" | sed 's/max_input_time =.*/max_input_time = 0/')
	# sendmail config
	PHP_INI=$(echo "$PHP_INI" | sed 's/;mail.force_extra_parameters =.*/mail.force_extra_parameters = "-f %s"/')
	PHP_INI=$(echo "$PHP_INI" | sed 's/mail.add_x_header = Off/mail.add_x_header = On/')
	sudo echo "$PHP_INI" > /etc/php/7.4/fpm/php.ini
	sudo service php7.4-fpm restart

	# PHP 8.0
	touch /home/vagrant/.homestead-features/php
	sudo chmod 777 /etc/php/8.0/fpm/php.ini
	PHP_INI=$(cat /etc/php/8.0/fpm/php.ini)
	PHP_INI=$(echo "$PHP_INI" | sed 's/upload_max_filesize =.*/upload_max_filesize = 0/')
	PHP_INI=$(echo "$PHP_INI" | sed 's/post_max_size =.*/post_max_size = 0/')
	PHP_INI=$(echo "$PHP_INI" | sed 's/max_execution_time =.*/max_execution_time = 0/')
	PHP_INI=$(echo "$PHP_INI" | sed 's/max_input_time =.*/max_input_time = 0/')
	# sendmail config
	PHP_INI=$(echo "$PHP_INI" | sed 's/;mail.force_extra_parameters =.*/mail.force_extra_parameters = "-f %s"/')
	PHP_INI=$(echo "$PHP_INI" | sed 's/mail.add_x_header = Off/mail.add_x_header = On/')
	sudo echo "$PHP_INI" > /etc/php/8.0/fpm/php.ini
	sudo service php8.0-fpm restart
fi
# End PHP



# Check if NGINX has been configured
if [ -f /home/vagrant/.homestead-features/nginx ]
then
    echo "NGINX already configured."
else
	touch /home/vagrant/.homestead-features/nginx
	sudo chmod 777 /etc/nginx/nginx.conf
	NGINX_CONF=$(cat /etc/nginx/nginx.conf)
	NGINX_CONF=$(echo "$NGINX_CONF" | sed 's/http {/http {\nclient_max_body_size 0;/')
	sudo echo "$NGINX_CONF" > /etc/nginx/nginx.conf
	sudo systemctl restart nginx
fi
# End NGINX



# Check if sendmail has been installed and configured
if [ -f /home/vagrant/.homestead-features/sendmail ]
then
    echo "sendmail already configured."
else
	touch /home/vagrant/.homestead-features/sendmail
	yes | sudo apt-get install sasl2-bin
	yes | sudo apt-get install sendmail
	yes | sudo sendmailconfig
	sudo mkdir /etc/mail/authinfo
	sudo chmod 777 /etc/mail/authinfo
	sudo echo 'AuthInfo: "U:root" "I:'$MAILUSER'" "P:'$MAILPASSWORD'"' > /etc/mail/authinfo/gmail-auth
	sudo makemap hash /etc/mail/authinfo/gmail-auth < /etc/mail/authinfo/gmail-auth
	sudo chmod 777 /etc/mail/sendmail.mc
	SENDMAILMC=$(cat /etc/mail/sendmail.mc)
	NEWSENDMAILMCSETTINGS=$(echo -e "\ndefine(\`SMART_HOST',\`[smtp.gmail.com]')dnl\ndefine(\`RELAY_MAILER_ARGS', \`TCP \$h 587')dnl\ndefine(\`ESMTP_MAILER_ARGS', \`TCP \$h 587')dnl\ndefine(\`confAUTH_OPTIONS', \`A p')dnl\nTRUST_AUTH_MECH(\`EXTERNAL DIGEST-MD5 CRAM-MD5 LOGIN PLAIN')dnl\ndefine(\`confAUTH_MECHANISMS', \`EXTERNAL GSSAPI DIGEST-MD5 CRAM-MD5 LOGIN PLAIN')dnl\nFEATURE(\`authinfo',\`hash -o /etc/mail/authinfo/gmail-auth.db')dnl")
	SENDMAILMC="${SENDMAILMC}${NEWSENDMAILMCSETTINGS}"
	SENDMAILMC=$(echo "$SENDMAILMC" | sed 's/MAILER_DEFINITIONS/dnl #/')
	SENDMAILMC=$(echo "$SENDMAILMC" | sed 's/MAILER(`local.*/dnl #/')
	SENDMAILMC=$(echo "$SENDMAILMC" | sed 's/MAILER(`smtp.*/dnl #/')
	MAILERDEFINITIONS=$(echo -e "\nMAILER_DEFINITIONS\nMAILER(\`local')dnl\nMAILER(\`smtp')dnl")
	SENDMAILMC="${SENDMAILMC}${MAILERDEFINITIONS}"
	sudo echo "$SENDMAILMC" > /etc/mail/sendmail.mc
	sudo make -C /etc/mail
	sudo /etc/init.d/sendmail reload
	yes | sudo sendmailconfig
	sudo chmod 777 /etc/hosts
	HOSTS=$(cat /etc/hosts)
	HOSTS=$(echo "$HOSTS" | sed 's/localhost/localhost\.localdomain localhost homestead/')
	sudo echo "$HOSTS" > /etc/hosts
	sudo systemctl restart nginx
fi
# End sendmail


# Check if env variables have been configured
if [ -f /home/vagrant/.homestead-features/envvariables ]
then
    echo "sendmail already configured."
else
	touch /home/vagrant/.homestead-features/envvariables
	echo "export SS_VENDOR_METHOD=none" >> /home/vagrant/.profile
	echo "export SS_VENDOR_METHOD=none" >> /home/vagrant/.bashrc
fi
