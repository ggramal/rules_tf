#!/usr/bin/env bash
set -o pipefail -o errexit -o nounset

readonly TAR="{{tar_path}}"
readonly TF="{{tf_path}}"
readonly TF_DIR="{{tf_dir}}"
readonly TF_BACKEND="{{tf_backend}}"
readonly OUT_TAR="{{out_tar}}"
${TF} -chdir=${TF_DIR} init -backend=${TF_BACKEND}
${TAR} -C ${TF_DIR} -czf ${OUT_TAR} .terraform
