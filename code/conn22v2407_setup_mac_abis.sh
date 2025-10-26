#!/bin/bash

cd ~/Downloads
curl -O https://www.nitrc.org/frs/download.php/16713/conn22v2407.zip
mkdir -p ~/conn/
if [ ! -d ~/conn/conn22v2407 ]; then
  unzip conn22v2407.zip -d /tmp/ && mv /tmp/conn  ~/conn/conn22v2407
  echo "CONN 22v2407 のセットアップができました"
  echo "MATLABで $HOME/conn/conn22v2407 をパスに加えてください"
else
  echo "conn22v2407 はすでにセットアップされています"
fi

