#!/usr/bin/env bash
set -euo pipefail
set -x

sudo su

if ! command -v k0s; then
  curl -sSLf https://get.k0s.sh | K0S_VERSION=v1.23.3+k0s.0 sh
fi

k0s version

public_ip=$(curl ip.jes.fi)
k0s config create > $HOME/k0s.yaml
k0s_config_before_sans=$(cat $HOME/k0s.yaml | grep "sans:" -B999)
k0s_config_after_sans=$(cat $HOME/k0s.yaml | grep "sans:" -A999 | tail -n+2)

echo "$k0s_config_before_sans" > $HOME/k0s.yaml
echo "    - $public_ip" >> $HOME/k0s.yaml
echo "$k0s_config_after_sans" >> $HOME/k0s.yaml

sed -i "s/address:.*/address: $public_ip/g" $HOME/k0s.yaml

#screen -dmS k0s -- sudo k0s server --single --config $HOME/k0s.yaml

screen -dmS k0s -- k0s server --single --config $HOME/k0s.yaml

while true; do
  k0s kubectl get node && break
  sleep 1
done

echo "k0s ok"