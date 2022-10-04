<p align="center"><img src="/art/logo.svg" alt="Laravel Homestead Logo"></p>

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

Laravel Homestead is an official, pre-packaged Vagrant box that provides you a wonderful development environment without requiring you to install PHP, a web server, or any other server software on your local machine. No more worrying about messing up your operating system! Vagrant boxes are completely disposable. If something goes wrong, you can destroy and re-create the box in minutes!

Homestead runs on any Windows, Mac, or Linux system, and includes the Nginx web server, PHP, MySQL, Postgres, Redis, Memcached, Node, and all of the other goodies you need to develop amazing Laravel applications.

Official documentation [is located here](https://laravel.com/docs/homestead).

#### Components

Homestead is made up of 2 different projects. The first is this repo which is the *Homestead application* itself. The application is a wrapper around Vagrant which is an API consumer of a virtualization hypervisor, or provider such as Virtualbox, Hyper-V, VMware, Or Parallels. The second part of Homestead is *Settler*, which is essentially JSON & Bash scripts to turn a minimalistic Ubuntu OS into what we call *Homestead base box*. Homestead and Settler (AKA *Homestead Base / Base Box*) combined give you the Homestead development environment.

> When you run `vagrant up` for the first time Vagrant will download the large base box from Vagrant cloud. The base box is the output from Settler. The base box will be stored at `~/.vagrant.d/` and copied to the folder you ran vagrant up command from in a hidden folder named `.vagrant`. This is what allows vagrant to create a VM and destroy it quickly and without having to download the large base box again.

##### Current versions
| Ubuntu LTS | Settler Version | Homestead Version | Branch    | Status               |
|------------|-----------------|-------------------|-----------|----------------------|
| 22.04      | 14.x            | 15.x              | `main`    | Development/Unstable |
| 22.04      | 14.x            | 15.x              | `release` | Stable               |

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

	192.168.56.56           phpmyadmin.local

Login:
- user: homestead
- password: secret

### sendmail
- Not required for Laravel. Mail configuration is set in the project .env
- Send test email `echo "test message" | sendmail -v youremail@gmail.com` (this could take several minutes to receive)

### apache2
- Used for 301 redirects
- Disable nginx `sudo systemctl stop nginx`
- `sudo vi /etc/apache2/apache2.conf`
- Update `<Directory />` block

        <Directory />
                Options FollowSymLinks
                AllowOverride All
                Require all granted
        </Directory>

- Add site conf `sudo vi /etc/apache2/sites-available/sitename.local.conf`

        <VirtualHost *:80>
            ServerAdmin email@email.com
            DocumentRoot /home/vagrant/sitename/public
            ServerName sitename.local
        </VirtualHost>

- Add symlink to sites-enabled `sudo ln -s /etc/apache2/sites-available/sitename.local.conf /etc/apache2/sites-enabled/sitename.local.conf`
- Restart apache `sudo systemctl restart apache2`

## Config
### Homestead.yaml

    folders:
        - map: 'C:/Users/YourUser/LaravelApps/sitename'
          to: /home/vagrant/sitename
    sites:
        - map: sitename.local
          to: /home/vagrant/sitename/public
          php: '7.3'
    databases:
        - sitename
    features:
        - mariadb: true

- SilverStripe sites will typically use php 7.3
- Laravel apps will typically use php 7.4

### Start Homestead
- Run `vagrant up --provision`
- Run `vagrant ssh`

## PHP Versions
### Composer
- Run composer with different versions of PHP `php7.4 /usr/local/bin/composer update`

### Artisan
- Run artisan with different versions of PHP `php7.4 artisan migrate`
