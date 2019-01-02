FROM alpine:3.7

LABEL maintainer="mritd <mritd1234@gmail.com>"

ARG TZ="Asia/Shanghai"

ENV TZ ${TZ}
ENV SS_LIBEV_VERSION 3.1.3
ENV KCP_VERSION 20181230 
ENV RAW_VERSION 20181113.0
ENV SERVER_IP 127.0.0.1
ENV UDP2RAW_SERVER_PORT 26817


RUN apk upgrade --update \
    && apk add bash tzdata openssh nano \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
    && ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N '' \
    && ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' \
    && ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' \
    && ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key -N '' \
    && echo "root:root" | chpasswd \
    && rm -rf /var/cache/apk/*
    


RUN apk upgrade --update \
    && apk add bash tzdata libsodium iptables net-tools \
    && apk add --virtual .build-deps \
        autoconf \
        automake \
        asciidoc \
        xmlto \
        build-base \
        curl \
        libev-dev \
        libtool \
        c-ares-dev \
        linux-headers \
        udns-dev \
        libsodium-dev \
        mbedtls-dev \
        pcre-dev \
        udns-dev \
        tar \
        git \
    && curl -sSLO https://github.com/xtaci/kcptun/releases/download/v$KCP_VERSION/kcptun-linux-amd64-$KCP_VERSION.tar.gz \
    && tar -zxf kcptun-linux-amd64-$KCP_VERSION.tar.gz \
    && mv server_linux_amd64 /usr/bin/kcpserver \
    && mv client_linux_amd64 /usr/bin/kcpclient \
    && curl -sSLO https://github.com/wangyu-/udp2raw-tunnel/releases/download/$RAW_VERSION/udp2raw_binaries.tar.gz \
    && tar -zxf udp2raw_binaries.tar.gz \
    && mv udp2raw_amd64 /usr/bin/udpraw \
    && ln -sf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && runDeps="$( \
        scanelf --needed --nobanner /usr/bin/ss-* \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | xargs -r apk info --installed \
            | sort -u \
        )" \
    && apk add --no-cache --virtual .run-deps $runDeps \
    && apk del .build-deps \
    && rm -rf kcptun-linux-amd64-$KCP_VERSION.tar.gz \
        shadowsocks-libev-$SS_LIBEV_VERSION.tar.gz \
        shadowsocks-libev-$SS_LIBEV_VERSION \
        udp2raw_binaries.tar.gz \
        /var/cache/apk/*

ADD kcp.sh /root/kcp.sh   
RUN chmod +x /root/kcp.sh
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh


EXPOSE 8964
ENTRYPOINT ["/entrypoint.sh"]    
