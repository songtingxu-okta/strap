#!/usr/bin/env bash

set -Eeuo pipefail # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
if ! command -v strap::lib::import >/dev/null; then
  echo "This file is not intended to be run or sourced outside of a strap execution context." >&2
  [[ "${BASH_SOURCE[0]}" != "${0}" ]] && return 1 || exit 1 # if sourced, return 1, else running as a command, so exit
fi

strap::lib::import lang || . lang.sh
strap::lib::import logging || . logging.sh
strap::lib::import path || . path.sh

strap::yum::pkg::is_installed() {
  local package_id="${1:-}" && strap::assert::has_length "$package_id" '$1 must be the package id'
  sudo yum list installed "$package_id" >/dev/null 2>&1
}

strap::yum::pkg::install() {
  local package_id="${1:-}" && strap::assert::has_length "$package_id" '$1 must be the package id'
  sudo yum -y install "$package_id"
}

##
# Ensures any initialization or setup for yum is required.  This can be a no-op if yum is always already installed
# on the host OS before strap is run.
##
strap::yum::init() {
  if ! strap::yum::pkg::is_installed 'epel-release'; then # needed for jq and maybe others
    strap::yum::pkg::install 'epel-release'
  fi
  if ! strap::yum::pkg::is_installed 'ius-release'; then # needed for git2u (up to date git and git-credential-libsecret) and python3
    sudo yum -y install 'https://repo.ius.io/ius-release-el7.rpm'
  fi
}
