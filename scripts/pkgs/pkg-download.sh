#!/usr/bin/env bash

set -o errexit
set -o nounset

#
# Script state init
#
script_dir="$(cd "$(dirname "${0}")" && pwd)"
cd "${script_dir}/../../"

base_url="https://cdn.platforma.bio/internal/pkgs/cellranger"

if [ "$#" -ne 3 ]; then
    echo ""
    echo "Usage: '${0}' <version> <os> <arch>"
    echo "       '${0}' 9.0.0 linux x64"
    echo ""
    echo "  OS list:"
    echo "    linux"
    echo "    windows"
    echo "    macosx"
    echo ""
    echo "  Arch list:"
    echo "    x64"
    echo "    aarch64"
    echo ""
    exit 1
fi

#
# Script parameters
#
version="${1}"
os="${2}"
arch="${3}"
dst_root="dld"
dst_data_dir="${dst_root}/cellranger-${version}-${os}-${arch}"


if [ "${os}" == "linux" ] && [ "${arch}" == "aarch64" ];then
    mkdir -p "${dst_data_dir}"
    exit 0
fi

if [ "${os}" == "macosx" ] && [ "${arch}" == "aarch64" ];then
    mkdir -p "${dst_data_dir}"
    exit 0
fi

if [ "${os}" == "macosx" ] && [ "${arch}" == "x64" ];then
    mkdir -p "${dst_data_dir}"
    exit 0
fi

if [ "${os}" == "windows" ] && [ "${arch}" == "x64" ];then
    mkdir -p "${dst_data_dir}"
    exit 0
fi

if [ "${os}" == "windows" ];then
    dst_archive_path="${dst_root}/cellranger-${version}-${os}-${arch}.zip"
else
    dst_archive_path="${dst_root}/cellranger-${version}-${os}-${arch}.tar.gz"
fi

case "${os}" in
"windows") 
    ext="zip" 
;;
"linux"|"macosx")
    ext="tar.gz"
;;
*)
    echo "unknown arch: ${os}"
    exit 1
;;
esac        

case "${arch}" in
"arm64"|"aarch64")
    arch="arm64"
;;
"amd64"|"x86_64"|"x64")
    arch="x64"
;;
*)
    echo "unknown arch: ${arch}"
    exit 1
;;
esac

function log() {
    printf "%s\n" "${*}"
}

function download() {
    local _ext=""
    local _suffix=""

    local _os="${os}"
    local _arch="${arch}"
    local _ext="${ext}"

    local _url="${base_url}/${version}/cellranger-${version}-${_os}-${_arch}.${_ext}"

    local _show_progress=("--show-progress")
    if [ "${CI:-}" = "true" ]; then
        _show_progress=()
    fi

    log "Downloading '${_url}'"
    wget --quiet "${_show_progress[@]}" --output-document="${dst_archive_path}" "${_url}"
}

function unpack() {
    log "Unpacking archive for ${os} to '${dst_data_dir}'"

    rm -rf "${dst_data_dir}"
    mkdir -pv "${dst_data_dir}"

    if [ "${os}" == "macos" ] || [ "${os}" == "linux" ];then
        tar -x \
            -f "${dst_archive_path}" \
            -C "${dst_data_dir}"
    else
        unzip -q "${dst_archive_path}" -d "${dst_data_dir}"
        mv "${dst_data_dir}/cellranger-${version}-${os}-${arch}" "${dst_data_dir}"
        rm -rf "${dst_data_dir}/cellranger-${version}-${os}-${arch}"
    fi        
}

mkdir -p "${dst_root}"
download
unpack
