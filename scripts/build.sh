#!/usr/bin/env bash

set -o errexit
set -o nounset

#
# Script state init
#
script_dir="$(cd "$(dirname "${0}")" && pwd)"

if [ "$#" -ne 1 ]; then
    echo ""
    echo "Usage: '${0}' <version>"
    echo "       '${0}' 9.0.0"
    echo ""
    exit 1
fi

#
# Script parameters
#
version="${1}"

${script_dir}/download.sh "${version}" linux x64

# Cellranger is available only for lixux x64
mkdir -p dld/linux-aarch64  # ${script_dir}/download.sh "${version}" linux aarch64
mkdir -p dld/macosx-x64     # ${script_dir}/download.sh "${version}" macosx x64
mkdir -p dld/macosx-aarch64 # ${script_dir}/download.sh "${version}" macosx aarch64
mkdir -p dld/windows-x64    # ${script_dir}/download.sh "${version}" windows x64

pl-pkg build --all-platforms
