pkg_name=prism
pkg_version=0.0.1
pkg_origin=chef
pkg_license=('Apache-2.0')
pkg_upstream_url=https://github.com/chef/prism
pkg_source=localsource.tar.gz
pkg_maintainer=dev@chef.io
pkg_deps=(core/bundler core/ruby)
pkg_build_deps=(
  core/coreutils
  core/gcc
  core/make
)
pkg_lib_dirs=(lib)
pkg_bin_dirs=(bin)

do_download() {
  return 0
}

do_strip() {
  return 0
}

do_verify() {
  return 0
}

do_unpack() {
  return 0
}

do_build() {
  mkdir -p "${pkg_name}"

  cp -r "${PLAN_CONTEXT}/../app/"* "${pkg_name}"
  export CPPFLAGS="${CPPFLAGS} ${CFLAGS}"

  local _bundler_dir=$(pkg_path_for bundler)

  export GEM_HOME="${pkg_path}/vendor/bundle"
  export GEM_PATH="${_bundler_dir}:${GEM_HOME}"

  cd "${pkg_name}"
  bundle install --jobs 2 --retry 5 --path vendor/bundle --binstubs
}

do_install() {
  cp -R . "${pkg_prefix}/dist"
}
