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
CURRENT_TOR_VERSION_URL=https://dist.torproject.org/${CURRENT_TOR_VERSION_FILENAME}
CURRENT_TOR_VERSION_SIG_URL=https://dist.torproject.org/${CURRENT_TOR_VERSION_FILENAME}.asc
echo "found TOR filename: ${CURRENT_TOR_VERSION_FILENAME}"
echo "downloading signature, adding key"
#TOR_GPG_KEY=$(gpg --batch --keyserver keys.openpgp.org --search-keys 0xEB5A896A28988BF5 | grep 'SA key' | sed -E 's/^.*SA key ([0-9A-Z]+), created.*/\1/g')
#gpg --keyserver keys.gnupg.net --recv-keys "${TOR_GPG_KEY}"
#TOR_GPG_KEY=$(gpg --batch --keyserver keys.openpgp.org --search-keys 0xC218525819F78451 | grep 'SA key' | sed -E 's/^.*SA key ([0-9A-Z]+), created.*/\1/g')
#gpg --keyserver keys.gnupg.net --recv-keys "${TOR_GPG_KEY}"
curl -fSsLO "${CURRENT_TOR_VERSION_SIG_URL}"

DONE=0
while [ $DONE -eq 0 ]; do
        #curl -fSsLO "${CURRENT_TOR_VERSION_URL}" && tar xf "${CURRENT_TOR_VERSION_FILENAME}" --strip-components 1 && gpg --verify "${CURRENT_TOR_VERSION_FILENAME}.asc" "${CURRENT_TOR_VERSION_FILENAME}"
        curl -fSsLO "${CURRENT_TOR_VERSION_URL}" && tar xf "${CURRENT_TOR_VERSION_FILENAME}" --strip-components 1
        [ $? -eq 0 ] && DONE=1 || {
                echo "failed getting tor browser from ${CURRENT_TOR_VERSION_URL}, sleeping 2 seconds and retrying"
                sleep 2
        }
done
