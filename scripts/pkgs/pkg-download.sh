#!/usr/bin/env bash

set -o errexit
set -o nounset

script_dir="$(cd "$(dirname "${0}")" && pwd)"
cd "${script_dir}/../../"

base_url="https://cdn.platforma.bio/internal/pkgs/cellranger"

if [ "$#" -ne 3 ]; then
    echo "Usage: '${0}' <version> <os> <arch>"
    echo "Example: '${0}' 9.0.0 linux x64"
    echo "OS list: linux, windows, macosx"
    echo "Arch list: x64, aarch64"
    exit 1
fi

version="${1}"
os="${2}"
arch="${3}"
dst_root="dld"
dst_data_dir="${dst_root}/cellranger-${version}-${os}-${arch}"

# Simplified arch and ext determination
case "${arch}" in
    "arm64"|"aarch64") arch="arm64" ;;
    "amd64"|"x86_64"|"x64") arch="x64" ;;
    *) echo "Unknown arch: ${arch}"; exit 1 ;;
esac

case "${os}" in
    "linux"|"macosx") ext="tar.gz" ;;
    "windows") ext="zip" ;;
    *) echo "Unknown OS: ${os}"; exit 1 ;;
esac

dst_archive_path="${dst_root}/cellranger-${version}-${os}-${arch}.${ext}"

# Simplify directory creation and exit early for specific unsupported combinations
mkdir -p "${dst_data_dir}"

# Check and skip specific combinations
if { [[ "${os}" == "linux" ]] && [[ "${arch}" == "arm64" ]]; } || 
   { [[ "${os}" == "macosx" ]] && [[ "${arch}" == "arm64" ]]; } || 
   { [[ "${os}" == "macosx" ]] && [[ "${arch}" == "x64" ]]; } || 
   { [[ "${os}" == "windows" ]] && [[ "${arch}" == "x64" ]]; }; then
    echo "Skipping unsupported combination: ${os}, ${arch}"
    exit 0
else
    echo "Proceeding with supported combination: ${os}, ${arch}"
    # Continue with the rest of the script if not exiting
fi

log() {
    printf "%s\n" "$@"
}

download() {
    local url="${base_url}/${version}/cellranger-${version}-${os}-${arch}.${ext}"
    local show_progress=()

    # Only add --show-progress if CI is not set to 'true'
    if [ "${CI:-false}" != "true" ]; then
        show_progress=("--show-progress")
    fi

    log "Downloading '${url}'"
    wget --quiet "${show_progress[@]}" --output-document="${dst_archive_path}" "${url}"
}

unpack() {
    log "Unpacking archive for ${os} to '${dst_data_dir}'"

    rm -rf "${dst_data_dir}"
    mkdir -pv "${dst_data_dir}"

    if [[ "${os}" == "macosx" || "${os}" == "linux" ]]; then
        tar -xf "${dst_archive_path}" -C "${dst_data_dir}"
    else
        unzip -q "${dst_archive_path}" -d "${dst_data_dir}"
        rm -rf "${dst_data_dir}/cellranger-${version}-${os}-${arch}"
    fi
}

mkdir -p "${dst_root}"
download
unpack