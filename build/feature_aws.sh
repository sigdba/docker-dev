shopt -s nullglob

case $(uname -m) in
    x86_64) SM_ARCH=64bit; CW_ARCH=amd64 ;;
    aarch64) SM_ARCH=arm64; CW_ARCH=arm64 ;;
    *) echo "UNKNOWN ARCH: $(uname -m)"; exit 1 ;;
esac

pip install awscli \
 && curl https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_${SM_ARCH}/session-manager-plugin.deb -o /tmp/session-manager-plugin.deb \
 && dpkg -i /tmp/session-manager-plugin.deb \
 && rm /tmp/session-manager-plugin.deb \
 && curl -Lo /cw.deb https://github.com/lucagrulla/cw/releases/download/v4.0.6/cw_${CW_ARCH}.deb \
 && dpkg -i /cw.deb \
 && rm -f /cw.deb \
 || die "installation error"

# TEMPORARY: https://github.com/Sceptre/sceptre/issues/1180
# RUN chmod -R a+rw /usr/local/lib/python3.8/site-packages
for P in /usr/local/lib/python*/site-packages/sceptre/cli/update.py; do
    echo "Patching $P"
    cp -f /build/sceptre_patch_update.py $P || die "sceptre patch error"
done
