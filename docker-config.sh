############### Configuration ###############
# this script is sourced by the build script
# here we specify the configs for the image that we are building
BASE_IMAGE=tensorflow/tensorflow:2.17.0-gpu

BASE_IMAGE_TAG=${BASE_IMAGE#*:};
BASE_IMAGE_NAME=${BASE_IMAGE%%:*};
case "$BASE_IMAGE_NAME" in
  tensorflow/tensorflow) IMAGE_NAME=tf-ssh;;
  *) echo >&2 "Error: unknown base image: $BASE_IMAGE_NAME"; exit 1;;
esac;

IMAGE_TAG=${IMAGE_TAG:-${BASE_IMAGE_TAG}}

IMAGE=${IMAGE_PREFIX}${IMAGE_NAME}${IMAGE_TAG+:}${IMAGE_TAG}
############# End Configuration #############
