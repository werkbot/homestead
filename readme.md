<p align="center"><img src="https://laravel.com/assets/img/components/logo-homestead.svg"></p>

<p align="center">
    <a href="https://github.com/laravel/homestead/actions">
        <img src="https://github.com/laravel/homestead/workflows/tests/badge.svg" alt="Build Status">
    </a>
    <a href="https://packagist.org/packages/laravel/homestead">
        <img src="https://img.shields.io/packagist/dt/laravel/homestead" alt="Total Downloads">
    </a>
    <a href="https://packagist.org/packages/laravel/homestead">
        <img src="https://img.shields.io/packagist/v/laravel/homestead" alt="Latest Stable Version">
    </a>
    <a href="https://packagist.org/packages/laravel/homestead">
        <img src="https://img.shields.io/packagist/l/laravel/homestead" alt="License">
    </a>
</p>

## Introduction

Laravel Homestead is an official, pre-packaged Vagrant box that provides you a wonderful development environment without requiring you to install PHP, a web server, and any other server software on your local machine. No more worrying about messing up your operating system! Vagrant boxes are completely disposable. If something goes wrong, you can destroy and re-create the box in minutes!

Homestead runs on any Windows, Mac, or Linux system, and includes the Nginx web server, PHP 8.0, MySQL, Postgres, Redis, Memcached, Node, and all of the other goodies you need to develop amazing Laravel applications.

Official documentation [is located here](https://laravel.com/docs/homestead).

Ubuntu 20.04 can be found in the branch `20.04` 

| Ubuntu LTS | Settler Version | Homestead Version | Branch      | Status
| -----------| -----------     | -----------       | ----------- | -----------
| 20.04      | 11.x            | 12.x              | `main`      | Development/Unstable
| 20.04      | 11.x            | 12.x              | `release`   | Stable

## Developing Homestead

To keep any in-development changes separate from other Homestead installations, create a new project and install
Homestead from composer, forcing it to use a git checkout.

```
$ mkdir homestead && \
    cd homestead && \
    composer require --prefer-source laravel/homestead:dev-main
```

After it's complete, `vendor/laravel/homestead` will be a git checkout and can be used normally.

## Extensions
### phpMyAdmin
Map site in Homestead.yaml:

    - map: phpmyadmin.local
      to: /home/vagrant/phpmyadmin
      php: '8.0'

Add site to main machine hosts file

	192.168.10.10           phpmyadmin.local

Login:
- user: homestead
- password: secret

## Config
### Homestead.yaml

    folders:
        - map: 'C:/Users/YourUser/LaravelApps/sitename'
          to: /home/vagrant/sitename
    sites:
        - map: sitename.local
          to: /home/vagrant/sitename/public
          php: '8.0'
    databases:
        - sitename
    features:
        - mysql: true

### Start Homestead
- Run `vagrant up --provision`
- Run `vagrant ssh`

### PHP
- Run `sudo vi /etc/php/8.0/fpm/php.ini`
- Change following values to 0:

        upload_max_filesize 0
        post_max_size 0
        max_execution_time 0
        max_input_time 0

### Nginx
- Run `sudo vi /etc/nginx/nginx.conf`
- Add `client_max_body_size 0;` in http brackets
- Run `sudo systemctl restart nginx`

## PHP Versions
### Composer
- Run composer with different versions of PHP `php7.4 /usr/local/bin/composer update`

### Artisan
- Run artisan with different versions of PHP `php7.4 artisan migrate`