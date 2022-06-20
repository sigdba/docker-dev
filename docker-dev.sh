#!/bin/bash

# Determine SCRIPT_DIR
[ -z "$SHELL" ] && SHELL=/bin/bash
case $(basename $SHELL) in
	zsh)
		SCRIPT_DIR=$(dirname $0:A)
		;;

	*)
		SCRIPT_DIR=$(cd $(dirname $0); pwd)
		;;
esac

die () {
  echo "ERROR: $*"
  exit 1
}

# Make SCRIPT_DIR absolute
SCRIPT_DIR="$(cd "$SCRIPT_DIR"; pwd -P)"

# Read site config
[ -f $SCRIPT_DIR/site.conf ] || die "site.conf not found. See site.conf.example"
. $SCRIPT_DIR/site.conf

# Figure out which md5 command to use
if which md5sum >/dev/null; then
  MD5CMD=md5sum
elif which md5 >/dev/null; then
  MD5CMD=md5
else
  die "No md5 command found. Install md5 or md5sum."
fi

# Expand DD_HOME
SCRIPT_END=$( awk '
  BEGIN { err=1; }
  /^\w*___END_OF_SHELL_SCRIPT___\w*$/ { print NR+1; err=0; exit 0; }
  END { if (err==1) print "?"; }
' "$0" )
if [ "$SCRIPT_END" == '?' ]; then
  DD_HOME=$SCRIPT_DIR/build
else
  DD_HOME=$SCRIPT_DIR/.docker-dev
  mkdir -p ${DD_HOME}
  tail -n +${SCRIPT_END} $0 |base64 -d |tar xjf - -C ${DD_HOME} || die "Error unpacking inline package"
fi

# Check if a rebuild is needed
cat_rebuilding_files () {
  cat $0 site.conf ${DD_HOME}/*
  [ -f $SCRIPT_DIR/requirements.txt ] && cat $SCRIPT_DIR/requirements.txt
}
TAG=$(cat_rebuilding_files |$MD5CMD |cut -d ' ' -f 1)
echo "Image Tag: $TAG"

IMAGE="dockerdev-${SITE_NAME}:$TAG"
HIST_FILE="$SCRIPT_DIR/.docker-dev-zsh_history"

[ -z "$(docker images -q $IMAGE 2> /dev/null)" ] && BUILD_IMAGE=y
[[ "$1" == '-b' ]] && BUILD_IMAGE=y
if [ -n "$BUILD_IMAGE" ]; then
  cd ${DD_HOME}
  if [ -f $SCRIPT_DIR/requirements.txt ]; then
    ln -sf ../requirements.txt ./requirements.txt
  else
    rm -f ./requirements.txt
    touch ./requirements.txt
  fi
  ln -sf ../site.conf ./site.conf
  TARBALL="${SCRIPT_DIR}/.-docker-dev-build-tmp.tar.gz"
  rm -f ${TARBALL} || die "Error removing old context tarball"
  tar czhf ${TARBALL} . || die "Error creating context tarball"
  cat ${TARBALL} | docker build -t "$IMAGE" - || die "docker build failed"
fi

touch "$HIST_FILE"

DOCKER_OPTS="$DOCKER_OPTS -e HOST_UID=$(id -u) -e HOST_GID=$(id -g) -e HOST_USERNAME=$(id -un) -v $HIST_FILE:/home/user/.zsh_history"

if [ -d "$HOME/.aws" ]; then
  DOCKER_OPTS="$DOCKER_OPTS --mount type=bind,source=$HOME/.aws,target=/home/user/.aws"
fi

if [ -d "$HOME/.ssh" ]; then
  DOCKER_OPTS="$DOCKER_OPTS --mount type=bind,source=$HOME/.ssh,target=/home/user/.ssh"
fi

if [ -d "$HOME/.c9" ]; then
  # We're in Cloud9
  DOCKER_OPTS="$DOCKER_OPTS -e IS_CLOUD9=true"
else
  # We're not in Cloud9
  DOCKER_OPTS="$DOCKER_OPTS -e AWS_PROFILE=$SITE_NAME"
fi

# DOCKER_OPTS="$DOCKER_OPTS -u 0:1000"

#
# This probably works on Linux but not on macos:
# https://github.com/docker/for-mac/issues/483
#
#if [ -n "$SSH_AUTH_SOCK" ]; then
#  SOCK_DIR="$(dirname $SSH_AUTH_SOCK)"
#  if [ -d "$SOCK_DIR" ]; then
#    DOCKER_OPTS="$DOCKER_OPTS -v $SOCK_DIR:$SOCK_DIR -e SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
#  else
#    echo "WARNING: SSH_AUTH_SOCK is set to '$SSH_AUTH_SOCK' but '$SOCK_DIR' is not a directory."
#  fi
#fi

docker run -ti --rm --mount type=bind,source="$SCRIPT_DIR",target=/repo $DOCKER_OPTS $IMAGE /bin/bash /launch.sh
