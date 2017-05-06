#!/bin/bash

# Proxy auto detect
if [ ! -e ~/.proxy.sh ]; then
	cp proxy.sh ~/.proxy.sh
	chmod +x ~/.proxy.sh
	echo "source ~/.proxy.sh" >> ~/.bashrc
fi
source ~/.proxy.sh
sudo sed -i 's/env_reset/env_keep += "PATH HOME EDITOR PAGER BROWSER ftp_proxy http_proxy https_proxy no_proxy HTTPS_PROXY HTTP_PROXY"/' /etc/sudoers

sudo apt-get update
sudo apt-get install -y python-software-properties curl
sudo add-apt-repository -y ppa:webupd8team/java
sudo add-apt-repository -y ppa:ubuntu-desktop/ubuntu-make

# NodeJS repo source
curl --silent https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -
DISTRO="$(lsb_release -s -c)"
sudo add-apt-repository -y "deb https://deb.nodesource.com/node_7.x $DISTRO main"

# Ubuntu partner repo
sudo add-apt-repository -y "deb http://archive.canonical.com/ubuntu $DISTRO partner"

[ -d debs ] && sudo cp --no-clobber debs/* /var/cache/apt/archives/

sudo debconf-set-selections <<< 'ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/dbconfig-install boolean true'
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/app-password-confirm password root'
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/admin-pass password root'
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/app-pass password root'
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2'
sudo debconf-set-selections <<< 'oracle-java8-installer shared/accepted-oracle-license-v1-1 boolean true'

sudo apt-get update
sudo apt-get dist-upgrade -y

debs=()
# Codecs and Media
debs+=(ubuntu-restricted-extras vlc clementine chromium-browser chromium-codecs-ffmpeg-extra)
# GUI Utils
debs+=(unity-tweak-tool geary)
# System tools
debs+=(laptop-mode-tools preload zram-config)
# VCS
debs+=(git subversion curl)
# Editors
debs+=(geany geany-plugins vim vim-gtk3)
# Apache2 & MySQL
debs+=(apache2 mysql-server mysql-client phpmyadmin libapache2-mod-php)
# PHP
debs+=(php phing composer)
debs+=(php-mysql php-mcrypt php-curl php-json php-mbstring php-cli)
debs+=(php-gd php-intl php-gettext php-xdebug)
debs+=(phpcpd phpmd phpunit phpunit-dbunit)
# Latex & Markup langs
debs+=(pandoc latex-beamer texlive texlive-full texlive-fonts-extra doxygen)
# Java/Android
debs+=(openjdk-8-jdk adb maven gradle oracle-java8-installer)
# Toolchains
debs+=(g++ gcc make)
# Nodejs
debs+=(nodejs)
# Ubuntu-Make
debs+=(ubuntu-make)


sudo apt-get install -y ${debs[@]}

sudo apt-get install -y oracle-java8-set-default

sudo apt-get remove -y unity-lens-shopping unity-scope-musicstores

# !! gsettings set com.canonical.Unity always-show-menu true

# [ -e android-studio.zip ] || curl -o android-sutio.zip https://dl.google.com/dl/android/studio/ide-zips/2.3.0.8/android-studio-ide-162.3764568-linux.zip
# [ -e phpstorm.tar.gz ] || curl -o phpstorm.tar.gz https://download-cf.jetbrains.com/webide/PhpStorm-2016.3.3.tar.gz

echo -e "${HOME}/.local/share/umake/android/android-studio\na" | umake android
echo -e "${HOME}/.local/share/umake/ide/phpstorm" | umake ide phpstorm
echo -e "${HOME}/.local/share/umake/ide/webstorm" | umake ide webstorm

# install Moncao font
mkdir -p ~/.local/share/fonts
curl -o ~/.local/share/fonts/monaco.ttf https://raw.githubusercontent.com/todylu/monaco.ttf/master/monaco.ttf
sudo fc-cache -f

cat <<EOF
**TODO**

- disable scopes:
  - amazon
  - ebay
  - online music search
- FR packages
- date 24H
- date/money format to Fr
- geary as default email client
- teamviewer skype
EOF
