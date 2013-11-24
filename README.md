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

2. Install [Transmission daemon](http://www.transmissionbt.com/)

  ```bash
  sudo apt-get install transmission-daemon
  ```
  
3. Install Hubot

  ```bash
  npm install -g hubot coffee-script
  ```

4. Install Redis
 
  ```bash
  cd ~/local
  wget http://download.redis.io/releases/redis-2.8.0.tar.gz
  tar xzf redis-2.8.0.tar.gz
  cd redis-2.8.0
  make
  ```

5. Launch Redis

  ```bash
  src/redis-server  
  ```
  
6. Generate structure for your Hubot and enter to the generated directory

  ```bash
  hubot --create myhubot
  cd myhubot
  ```

7. Add HubotClient as a dependency to package.json

  ```json
  "dependencies": {
    "hubot":         ">= 2.6.0 < 3.0.0",
    "hubot-scripts": ">= 2.5.0 < 3.0.0",
    "hubot-torrent": "git://github.com/dnesteryuk/hubot-torrent.git"
  },

  ```
  
8. Install all dependencies
 
  ```bash
  npm install
  ```

9. Enable Hubot torrent by adding following line to external-scripts.json

  ```json
  ["hubot-torrent"]
  ```

10. Run hubot and enjoy

  ```bash
  bin/hubot
  ```

