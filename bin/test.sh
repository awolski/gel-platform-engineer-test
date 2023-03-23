#!/usr/bin/env bash

set -eu

# Exit if terraform has not been applied
terraform output >/dev/null 2>&1 || exit 1

# Get bucket names
bucket_a=$(terraform output | grep bucket_a | cut -d '"' -f2)
bucket_b=$(terraform output | grep bucket_b | cut -d '"' -f2)

# And path to the test dir
test_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/../test"
target_file=$(date +%Y%m%d-%H%M%S).jpg

# Copy the test.jpg to bucket a
aws s3 cp ${test_dir}/test.jpg s3://${bucket_a}/${target_file}

# Simple loop to wait for processed image to land in bucket b
while
  cleaned_file="$(aws s3 ls ${bucket_b} | awk '{ print $4}' | grep ${target_file})"
  [ cleaned_file == "" ]
do true; done

# Copy the processed file to the test directory
aws s3 cp "s3://${bucket_b}/${target_file}" test/
