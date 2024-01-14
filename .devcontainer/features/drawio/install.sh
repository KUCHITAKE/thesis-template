#!/bin/sh

set -e


VERSION=${VERSION:-"22.1.18"}

check_packages() {
	if ! dpkg -s "$@" >/dev/null 2>&1; then
		if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
			echo "Running apt-get update..."
			apt-get update -y
		fi
		apt-get -y install --no-install-recommends "$@"
	fi
}

check_packages xvfb wget libgbm1 libasound2
wget https://github.com/jgraph/drawio-desktop/releases/download/v$VERSION/drawio-$(dpkg --print-architecture)-$VERSION.deb -O /tmp/drawio.deb
apt-get install -y /tmp/drawio.deb
rm /tmp/drawio.deb

# cleanup
rm -rf /var/lib/apt/lists/*

echo "Done!"