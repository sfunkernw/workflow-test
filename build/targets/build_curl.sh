#!/bin/bash
set -e
set -x
set -o pipefail
if [ "$#" -ne 1 ];then
    echo "Usage: ${0} [x86|x86_64|armhf|aarch64]"
    echo "Example: ${0} x86_64"
    exit 1
fi
source $GITHUB_WORKSPACE/build/lib.sh
init_lib "$1"

build_curl() {
    fetch "https://github.com/curl/curl.git" "${BUILD_DIRECTORY}/curl" git
    cd "${BUILD_DIRECTORY}/curl"
    git clean -fdx
    git checkout master
    mkdir binary/
    ./buildconf
    autoreconf -vif
    ./configure --disable-shared --enable-static --prefix=${BUILD_DIRECTORY}/curl/binary
    make
    pwd
    ls -la binary/
    ls -la binary/usr/local/bin/
    cp binary/usr/local/bin/curl .
    strip curl
}

main() {
    build_curl
    local version
    version=$(get_version "${BUILD_DIRECTORY}/curl/curl --version 2>&1 | head -n1 | awk '{print \$2}'")
    cp "${BUILD_DIRECTORY}/curl/curl" "${OUTPUT_DIRECTORY}/curl"
    echo "[+] Finished building curl ${CURRENT_ARCH}"

    echo ::set-output name=PACKAGED_NAME::"curl${version}"
    echo ::set-output name=PACKAGED_NAME_PATH::"${OUTPUT_DIRECTORY}/*"
}

main
