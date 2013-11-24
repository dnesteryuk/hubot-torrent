hubot-torrent
=============

Torrent client for Hubot

# Installation

1. Install NodeJs and Npm (if you have it installed, you can skip this step)

```shell
echo 'export PATH=$HOME/local/bin:$PATH' >> ~/.bashrc

. ~/.bashrc
mkdir ~/local
mkdir ~/node-latest-install

cd ~/node-latest-install
curl http://nodejs.org/dist/node-latest.tar.gz | tar xz --strip-components=1

./configure --prefix=~/local --without-snapshot # the last argument is required for ARM processors

make install

curl https://npmjs.org/install.sh | sh
```

2. Install Transmission-daemon

```shell
sudo apt-get install transmission-daemon
```