#!/bin/bash

for f in $(find $BUILD_WORKSPACE_DIRECTORY/ -maxdepth 1 -type d | grep -v "${BUILD_WORKSPACE_DIRECTORY}/$")
do
    echo $f | grep "terraform_block_template" >/dev/null 2>&1 && touch $f/terraform_block_template.tfstate || touch $f/this.tfstate
done

