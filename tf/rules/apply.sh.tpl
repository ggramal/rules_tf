#!/usr/bin/env bash
readonly TAR="{{tar_path}}"
readonly TF="{{tf_path}}"
readonly TF_DIR="{{tf_dir}}"
readonly TF_INIT_TAR="{{tf_init_tar}}"
readonly TF_PARALLELISM="{{tf_parallelism}}"
readonly TF_PLAN="{{tf_plan}}"
readonly TF_PLAN_FILE=$(basename ${TF_PLAN})
readonly COREUTILS="{{coreutils_path}}"

${TAR} -C ${TF_DIR} -xzf ${TF_INIT_TAR}
${TF} -chdir=${TF_DIR} apply -parallelism=${TF_PARALLELISM} ${TF_PLAN}
readonly TF_EXIT=$?

# Invalidate plan build cache.
# This is needed because after apply 
# generated plan file becomes stale 
# and output of tf_plan target is cached
# so it will not be rebuilt
${COREUTILS} rm -f $(${COREUTILS} readlink ${TF_DIR}/${TF_PLAN})

exit $TF_EXIT
