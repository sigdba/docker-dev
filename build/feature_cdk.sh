export NODE_ENV=/build/node_env

echo "NODE_ENV=${NODE_ENV}; export NODE_ENV" >/etc/profile.d/node_env.sh || die "failed to create /etc/profile.d/node_env.sh"

cat >/etc/profile.d/node_env.sh <<EOF
NODE_ENV=${NODE_ENV}; export NODE_ENV
. \$NODE_ENV/bin/activate
EOF

which nodeenv >/dev/null || die "add nodeenv to requirements.txt"

nodeenv $NODE_ENV \
 && . $NODE_ENV/bin/activate \
 && npm install -g typescript ts-node aws-cdk \
 || die "failed to configure node environment"
