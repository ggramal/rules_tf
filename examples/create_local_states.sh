#!/bin/bash

for f in $(find $BUILD_WORKSPACE_DIRECTORY/ -maxdepth 1 -type d | grep -v "${BUILD_WORKSPACE_DIRECTORY}/$")
do
    touch $f/this.tfstate
done

touch $BUILD_WORKSPACE_DIRECTORY/terraform_block_template/terraform_block_template.tfstate
