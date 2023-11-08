if [ -z "$SAML2AWS_TAR_URL" ]; then
    CURRENT_VERSION=$(curl -Ls https://api.github.com/repos/Versent/saml2aws/releases/latest | grep 'tag_name' | cut -d'v' -f2 | cut -d'"' -f1)
    SAML2AWS_TAR_URL="https://github.com/Versent/saml2aws/releases/download/v${CURRENT_VERSION}/saml2aws_${CURRENT_VERSION}_linux_amd64.tar.gz"
fi

wget -c "$SAML2AWS_TAR_URL" -O - | tar -xzv -C /usr/local/bin || die "Error installing saml2aws"
chmod u+x /usr/local/bin/saml2aws || die "chmod error"

hash -r
echo -n "saml2aws Version: "
saml2aws --version
