#!/bin/bash

#https://askubuntu.com/a/441536/543855
#https://www.gnu.org/software/bash/manual/html_node/Bash-Conditional-Expressions.html
#https://explainshell.com/

if [ -n "${DOMAINS}" ]; then
  DKIM_FILE="$(find /etc/opendkim/domainkeys -iname *.private)"

  if [ -n "$DKIM_FILE" ]; then
    DOMAINS_LIST="$(sed 's/[,;]\s*/\n/g' <<< "${DOMAINS}")"

    while [[ -n "$DOMAINS_LIST" ]] && read -r domain; do

      echo "Adding ${domain} to /etc/opendkim/TrustedHosts"
      cat >>/etc/opendkim/TrustedHosts <<EOF
$domain
EOF

      echo "Adding ${domain} to /etc/opendkim/KeyTable"
      cat >>/etc/opendkim/KeyTable <<EOF
${dkimselector:-default}._domainkey.$domain $domain:${dkimselector:-default}:$DKIM_FILE
EOF

      echo "Adding ${domain} to /etc/opendkim/SigningTable"
      cat >>/etc/opendkim/SigningTable <<EOF
*@$domain ${dkimselector:-default}._domainkey.$domain
EOF

    done <<< "$DOMAINS_LIST"
  fi
fi
