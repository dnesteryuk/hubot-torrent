# HubotTorrent

Torrent client for Hubot

# Installation

1. Install NodeJs and Npm

  ```bash
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

  ```bash
  sudo apt-get install transmission-daemon
  ```
  
3. Install Hubot

  ```bash
  npm install -g hubot coffee-script
  ```
  
4. Generate structure for your Hubot

  ```bash
  hubot --create myhubot
  ```

5. Add HubotClient as a dependency to myhubot/package.json

  ```json
  "dependencies": {
    "hubot":         ">= 2.6.0 < 3.0.0",
    "hubot-scripts": ">= 2.5.0 < 3.0.0",
    "hubot-torrent": "git://github.com/dnesteryuk/hubot-torrent.git"
  },

  ```
6. Install all dependencies
 
  ```bash
  cd myhubo
  npm install
  ```

7. Install Redis, you can use this
 
  ```bash
  cd ~/local
  wget http://download.redis.io/releases/redis-2.8.0.tar.gz
  tar xzf redis-2.8.0.tar.gz
  cd redis-2.8.0
  make
  ```

8. Launch Redis

  ```bash
  src/redis-server  
  ```

9. Run hubot from the directory where you have generated it to and enjoy

  ```bash
  bin/hubot
  ```

