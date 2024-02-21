#!/usr/bin/env bash
set -o pipefail -o errexit -o nounset

readonly TAR="{{tar_path}}"
readonly TF="{{tf_path}}"
readonly TF_DIR="{{tf_dir}}"
readonly TF_INIT_TAR="{{tf_init_tar}}"
readonly TF_PARALLELISM="{{tf_parallelism}}"
readonly TF_OUT="{{tf_out}}"
readonly TF_OUT_FILE=$(basename ${TF_OUT})
readonly COREUTILS="{{coreutils_path}}"

${TAR} -C ${TF_DIR} -xzf ${TF_INIT_TAR}
${TF} -chdir=${TF_DIR} plan -out=${TF_OUT_FILE} -parallelism=${TF_PARALLELISM}
${COREUTILS} cp ${TF_DIR}/${TF_OUT_FILE} ${TF_OUT}
