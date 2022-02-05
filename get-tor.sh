#!/bin/bash -eu
# shellcheck disable=SC2181,SC2015

curl -fSsL https://dist.torproject.org/ > tor_download_page
if [ $? -ne 0 ]; then
        echo "Failed getting torproject download page, bailing"
        exit 2
fi
CURRENT_TOR_VERSION=$(grep 'tor-.*tar.gz"' tor_download_page | sed -E 's/^.*href="tor-([0-9\.]+)\.tar\.gz".*$/\1/g' | grep -E '^[0-9\.]+$' | sort -V | tail -1)
rm tor_download_page
CURRENT_TOR_VERSION_FILENAME=tor-${CURRENT_TOR_VERSION}.tar.gz
CURRENT_TOR_VERSION_SIGNATURE_FILENAME=${CURRENT_TOR_VERSION_FILENAME}.sha256sum.asc
CURRENT_TOR_VERSION_URL=https://dist.torproject.org/${CURRENT_TOR_VERSION_FILENAME}
CURRENT_TOR_VERSION_SIG_URL=https://dist.torproject.org/${CURRENT_TOR_VERSION_SIGNATURE_FILENAME}
echo "found TOR filename: ${CURRENT_TOR_VERSION_FILENAME}"
echo "found signature file: ${CURRENT_TOR_VERSION_SIGNATURE_FILENAME}"
echo "downloading signature, adding key"
curl -fSsLO "${CURRENT_TOR_VERSION_SIG_URL}"
echo "downloading archive"
DONE=0
while [ $DONE -eq 0 ]; do
        curl -fSsLO "${CURRENT_TOR_VERSION_URL}" && tar xf "${CURRENT_TOR_VERSION_FILENAME}" --strip-components 1
        [ $? -eq 0 ] && DONE=1 || {
                echo "failed getting tor browser from ${CURRENT_TOR_VERSION_URL}, sleeping 2 seconds and retrying"
                sleep 2
        }
done
echo "verifying archive ${CURRENT_TOR_VERSION_FILENAME} with ${CURRENT_TOR_VERSION_SIGNATURE_FILENAME}"
sha256sum "${CURRENT_TOR_VERSION_FILENAME}.sha256sum.asc"
[ $? -eq 0 ] || {
        echo "Failed verifying shasum, bailing!"
        exit 2
}