[ -z "$AWS_SAM_VER" ] && die "AWS_SAM_VER not set. Add AWS_SAM_VER to site.conf"

wget -O /sam.zip "https://github.com/aws/aws-sam-cli/releases/download/v${AWS_SAM_VER}/aws-sam-cli-linux-x86_64.zip" || die "error downloading SAM"

if [ -z "$AWS_SAM_SUM" ]; then
    echo "WARNING: You should set AWS_SAM_SUM in site.conf for safety"
else
    echo "$AWS_SAM_SUM  /sam.zip" | sha256sum -c - || die "SAM package did not match checksum"
fi

unzip /sam.zip -d /sam-install \
 && /sam-install/install \
 && rm -Rf /sam.zip /sam-install \
 && sam --version \
 || die "sam install failed"
