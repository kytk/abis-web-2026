#!/bin/bash

cd ~/Downloads
curl -OL https://github.com/spm/spm/releases/download/25.01.02/spm_25.01.02.zip

mkdir -p ~/spm/
if [ ! -d ~/spm/spm25 ]; then
  unzip spm_25.01.02.zip -d /tmp/ && mv /tmp/spm ~/spm/spm25
  echo "SPM25 のセットアップができました"
  echo "Matlabで $HOME/spm/spm25 をパスに加えてください"
else
  echo "SPM25はすでに準備されています"
fi

