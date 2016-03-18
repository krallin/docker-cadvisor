#!/bin/bash
set -o errexit
set -o nounset

RUN_DEPS=(dmsetup ca-certificates apache2-utils)
BUILD_DEPS=(golang-src git build-essential curl)
GO_DEPS=(github.com/tools/godep)


# Grab essential build dependencies
apt-install "${RUN_DEPS[@]}"
apt-install "${BUILD_DEPS[@]}"

# Now, install a recent version of Go
GODIST="/godist"
GOLANG_VERSION=1.6
GOLANG_DOWNLOAD_URL="https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz"
GOLANG_DOWNLOAD_SHA256="5470eac05d273c74ff8bac7bef5bad0b5abbd1c4052efbdbc8db45332e836b0b"

curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz
echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c -

mkdir -p "$GODIST"
tar -C "$GODIST" -xzf golang.tar.gz
rm golang.tar.gz

export GOROOT="${GODIST}/go"
export GOPATH="/go"
export PATH="${GOPATH}/bin:${GOROOT}/bin:${PATH}"

# Get Go build dependencies
go get "${GO_DEPS[@]}"

# Get cadvisor
CADVISOR="github.com/google/cadvisor"
go get -d "$CADVISOR" || true  # Usually an error about an expected import that doesn't matter..!
cd "${GOPATH}/src/${CADVISOR}"

# Check out what we're building, and apply our patch series
git checkout "$CADVISOR_VERSION"

for patchfile in /patches/*.patch; do
  echo "Applying ${patchfile}"
  patch -p1 -d . < "$patchfile"
done

make

# Move cavisor to our deploy path
mv cadvisor /usr/local/bin

# And blow away ALL the deps
cd /
rm -rf "$GOPATH"
rm -rf "$GODIST"
apt-get remove -y "${BUILD_DEPS[@]}"
apt-get autoremove -y

# Check that cadvisor still runs
cadvisor -version

# Check that some binaries cadvisor relies on are present
which nice
which du
which chroot
which dmsetup
