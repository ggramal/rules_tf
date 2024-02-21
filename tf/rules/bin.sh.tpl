#!/usr/bin/env bash
set -o pipefail -o errexit -o nounset

readonly TAR="{{tar_path}}"
readonly TF="{{tf_path}}"
readonly TF_DIR="{{tf_dir}}"
readonly TF_INIT_TAR="{{tf_init_tar}}"

${TAR} -C ${TF_DIR} -xzf ${TF_INIT_TAR}
${TF} -chdir=${TF_DIR} $@
