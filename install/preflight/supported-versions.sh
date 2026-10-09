SUPPORTED_VERSIONS=("24.04" "26.04")

omakub_ubuntu_version_supported() {
  local version="$1"
  local supported_version

  for supported_version in "${SUPPORTED_VERSIONS[@]}"; do
    [[ $version == "$supported_version" ]] && return 0
  done

  return 1
}
