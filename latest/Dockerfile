FROM kingsquare/postfix:latest

RUN set -ex; \
    { \
        echo 'devnull:/dev/null'; \
    } >> /etc/aliases; \
    \
    { \
        #https://askubuntu.com/a/63691/543855
        echo 'always_bcc = backup'; \
    } >> /etc/postfix/main.cf;
