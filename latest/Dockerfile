FROM kingsquare/postfix:latest

RUN set -ex; \
    #https://superuser.com/a/353526
    sed -i \
    -e 's/^\(alias_maps = \)hash/\1regexp/' \
    -e 's/^\(alias_database = \)hash/\1regexp/' \
    /etc/postfix/main.cf; \
    \
    { \
        echo '/^devnull(\d*)@/ /dev/null'; \
    } >> /etc/aliases; \
    \
    { \
        #https://askubuntu.com/a/63691/543855
        echo 'always_bcc = backup'; \
    } >> /etc/postfix/main.cf;
    #\
    #http://postfix.1071664.n5.nabble.com/first-timer-using-postmap-help-please-td14908.html
    #newaliases;
