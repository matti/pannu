#!/usr/bin/env bash
# requires 4 cpu, 8gb ram says installer

set -euo pipefail

sudo apt-get update
sudo apt-get install -y git screen socat

set +e
  docker volume ls -q | grep sentry- | xargs docker volume rm -f
set -e

rm -rf self-hosted
git clone https://github.com/matti/self-hosted

cd self-hosted
  git fetch --all --tags
  git checkout "tags/${SENTRY_TAG}" -b latest

  if [ ! -d sentry/sentry-self-hosted-tools ]; then
    cd sentry
      git clone https://github.com/matti/sentry-self-hosted-tools
    cd ..
  fi

  ./install.sh --no-user-prompt

  docker-compose up -d

  while true; do
    docker-compose exec -T web sentry createuser --email "${SENTRY_EMAIL}" --password "${SENTRY_PASSWORD}" --superuser && break
    sleep 1
  done

  for project in ${SENTRY_PROJECTS}; do
    name=$(echo $project | cut -d: -f1)
    id=$(echo $project | cut -d: -f2)

    echo "name: $name"
    echo "id: $id"

    docker-compose exec -T web sentry exec /etc/sentry/sentry-self-hosted-tools/project-create-static.py --name "${name}" --id "${id}"
  done

  sudo screen -dmS fwd-80-to-9000 /usr/bin/socat TCP-LISTEN:80,fork TCP:127.0.0.1:9000

  echo "OK"