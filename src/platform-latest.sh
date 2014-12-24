#!/bin/bash

MANTA_URL=http://us-east.manta.joyent.com
LATEST_POINTER=${MANTA_URL}/Joyent_Dev/public/builds/platform/master-latest
LATEST_DIR=$(curl ${LATEST_POINTER} 2>/dev/null)
LATEST_VER=${LATEST_DIR##*-}
PLATFORM=${MANTA_URL}${LATEST_DIR}/platform/platform-master-${LATEST_VER}.tgz

cd $(dirname $0)

if [[ -f platform/${LATEST_VER} ]]; then
	echo "Already up to date"
	exit 0
fi

curl $PLATFORM | gtar -C -xz && mv platform-${LATEST_VER} platform-new

if [[ -d platform-new ]]; then
	touch platform-new/${LATEST_VER}
	[[ -d platform-old ]] && rm -rf platform-old
	mv platform platform-old
	mv platform-new platform
else
	rm -rf platform-${LATEST_VER}
	echo "Failed!"
fi
