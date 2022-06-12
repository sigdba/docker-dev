curl https://raw.githubusercontent.com/sigdba/sig-shared-sceptre/main/templates/IamMfa/awsmfa.sh -o /opt/awsmfa.sh
chmod 755 /opt/awsmfa.sh

echo "alias awsmfa='eval \$(/opt/awsmfa.sh)'" >/etc/profile.d/awsmfa.sh
