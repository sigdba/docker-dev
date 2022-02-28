#!/bin/bash

die () {
    echo "ERROR: $*"
    exit 1
}
export -f die

require_feature () {
    echo "Adding feature: $1"
    FS=/build/feature_${1}.sh
    [ -f "$FS" ] || die "Script for feature '$1' not found: $FS"
    . $FS || die "failed adding feature '$1'"
}
export -f require_feature

. /build/site.conf
for feature in $(echo ${DOCKERDEV_FEATURES//,/$IFS}); do
    require_feature $feature
done
