#!/usr/bin/env bash

out=docker-dev.packaged.sh

cat docker-dev.sh >$out
cat >>$out <<'EOF'
exit 0

#
# What follows is a base64-encoded tarball compressed with bzip2. The tarball
# contains the ancillary scripts used by docker-dev.
#

EOF
echo "___END_OF_SHELL_SCRIPT___" >>$out
tar cvjf - -C build . |base64 >>$out

chmod 755 $out
