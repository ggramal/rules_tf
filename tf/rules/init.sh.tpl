#!/usr/bin/env bash
set -o pipefail -o errexit -o nounset

readonly TAR="{{tar_path}}"
readonly TF="{{tf_path}}"
readonly TF_DIR="{{tf_dir}}"
readonly OUT_TAR="{{out_tar}}"
${TF} -chdir=${TF_DIR} init
${TAR} -C ${TF_DIR} -czf ${OUT_TAR} .terraform
