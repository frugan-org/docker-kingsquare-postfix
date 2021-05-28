FROM kingsquare/postfix:latest

RUN set -ex; \
    #https://serverfault.com/a/644393/377751
    #https://superuser.com/a/353526
    { \
        echo 'devnull: /dev/null'; \
    } >> /etc/aliases; \
    \
    { \
        #https://askubuntu.com/a/63691/543855
        echo 'always_bcc = backup'; \
        #https://serverfault.com/a/696298/377751
        echo 'virtual_alias_maps = hash:/etc/postfix/virtual'; \
    } >> /etc/postfix/main.cf; \
    \
    { \
        echo '@localhost.localdomain devnull@localhost.localdomain'; \
    } > /etc/postfix/virtual; \
    \
    postmap /etc/postfix/virtual; \
    \
    #http://postfix.1071664.n5.nabble.com/first-timer-using-postmap-help-please-td14908.html
    newaliases;

COPY setup-postfix.sh /app/opt

#https://github.com/docker-library/postgres/issues/296#issuecomment-308735942
RUN chmod +x /app/opt/setup-postfix.sh
