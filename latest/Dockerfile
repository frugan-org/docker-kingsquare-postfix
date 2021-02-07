FROM kingsquare/postfix:latest

RUN set -ex; \
    #https://superuser.com/a/353526
    sed -i \
    -e 's/^\(alias_maps = \)hash/\1regex/' \
    -e 's/^\(alias_database = \)hash/\1regex/' \
    /etc/postfix/main.cf; \
    \
    { \
        echo '/^devnull(\d*)@/ /dev/null'; \
    } >> /etc/aliases; \
    \
    { \
        #https://askubuntu.com/a/63691/543855
        echo 'always_bcc = backup'; \
    } >> /etc/postfix/main.cf; \
    \
    newaliases;
