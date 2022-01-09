#!/bin/bash

#https://askubuntu.com/a/441536/543855
#https://www.gnu.org/software/bash/manual/html_node/Bash-Conditional-Expressions.html
#https://explainshell.com/


#https://rimuhosting.com/knowledgebase/linux/mail/Postfix%20mbox%20to%20Maildir%20conversion
#echo "Adding home_mailbox configurations to /etc/postfix/main.cf"
#postconf -e "home_mailbox = Maildir/"


echo "Configuring always_bcc"
#https://serverfault.com/a/644393/377751
#https://superuser.com/a/353526
{
  echo 'devnull: /dev/null';
} >> /etc/aliases;

{
  #https://askubuntu.com/a/63691/543855
  echo 'always_bcc = backup';
  #https://serverfault.com/a/696298/377751
  echo 'virtual_alias_maps = hash:/etc/postfix/virtual';
} >> /etc/postfix/main.cf;

{
  echo '@localhost.localdomain devnull@localhost.localdomain';
} > /etc/postfix/virtual;

postmap /etc/postfix/virtual;

#http://postfix.1071664.n5.nabble.com/first-timer-using-postmap-help-please-td14908.html
newaliases;


#https://github.com/roehling/postsrsd/issues/67
#https://github.com/roehling/postsrsd/issues/39
#https://stackoverflow.com/a/22877206/3929620
#https://stackoverflow.com/a/13745840/3929620
#https://serverfault.com/q/843510/377751
#https://serverfault.com/a/674984/377751
#https://stackoverflow.com/a/68819424/3929620
#https://serverfault.com/a/834729/377751
#https://stackoverflow.com/a/39381717/3929620
#https://stackoverflow.com/a/63024268/3929620
#https://contrid.net/server/mail-servers/postfix-catch-all-pipe-to-script/
#https://www.thejml.info/devops/passing-email-to-scripts-with-postfix
if [[ -f /etc/postfix/conf/header_checks.pcre ]]; then
  echo "Adding header_checks configurations to /etc/postfix/main.cf"
  postconf -e "header_checks = pcre:/etc/postfix/conf/header_checks.pcre"
fi

if [[ -f /etc/postfix/conf/smtp_header_checks.pcre ]]; then
  echo "Adding smtp_header_checks configurations to /etc/postfix/main.cf"
  postconf -e "smtp_header_checks = pcre:/etc/postfix/conf/smtp_header_checks.pcre"
fi


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


#https://serverfault.com/a/861701/377751
#https://serverfault.com/a/892672/377751
#https://serverfault.com/a/1048573/377751
#https://github.com/kingsquare/docker-postfix/pull/7
sed -i \
    -e 's/refile\:\(\/etc\/opendkim\/KeyTable\)/\1/' \
    /etc/opendkim.conf;


#https://github.com/docker-mailserver/docker-mailserver/blob/65622c56e934459beef7fba045f23ef897a6dcda/target/scripts/postsrsd-wrapper.sh
echo "Adding SRS_DOMAIN to /etc/default/postsrsd"
sed -i -e "s/^\(SRS_DOMAIN=\).*/\1${SRS_DOMAIN}/g" /etc/default/postsrsd

if [[ -n ${SRS_EXCLUDE_DOMAINS} ]]; then
  echo "Adding SRS_EXCLUDE_DOMAINS to /etc/default/postsrsd"
  sed -i -e "s/^#\?SRS_EXCLUDE_DOMAINS=.*$/SRS_EXCLUDE_DOMAINS=${SRS_EXCLUDE_DOMAINS}/g" /etc/default/postsrsd
fi

echo "Adding SRS configurations to /etc/postfix/main.cf"
postconf -e "sender_canonical_maps = tcp:localhost:10001"
postconf -e "sender_canonical_classes = ${SRS_SENDER_CLASSES}"
postconf -e "recipient_canonical_maps = tcp:localhost:10002"
postconf -e "recipient_canonical_classes = envelope_recipient,header_recipient"

#https://github.com/docker-mailserver/docker-mailserver/blob/bab0277723f46c00016eabd48ec3a932b1244bf5/target/supervisor/conf.d/supervisor-app.conf#L127
cat >>/etc/supervisor/conf.d/supervisord.conf <<EOF

[program:postsrsd]
command=/etc/init.d/postsrsd start
EOF
