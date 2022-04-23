#!/usr/bin/env bash
set -euo pipefail
set -x

if ! command -v docker; then
  sudo apt-get update
  sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --no-tty --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  fi

  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io
fi

if [ ! -f /etc/systemd/system/docker.service.d/override.conf ]; then
  sudo mkdir -p /etc/systemd/system/docker.service.d
  echo """
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://127.0.0.1:2375 --containerd=/run/containerd/containerd.sock
""" | sudo tee /etc/systemd/system/docker.service.d/override.conf
  sudo systemctl daemon-reload
  sudo systemctl restart docker
fi

set +e
  sudo addgroup $USER docker
set -e

sudo docker ps

echo "docker ok"

if ! command -v docker-compose; then
  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
fi

docker-compose version

echo "docker-compose ok"