FROM alpine:3.7

LABEL maintainer="mritd <mritd1234@gmail.com>"

ARG TZ="Asia/Shanghai"

ENV TZ ${TZ}
ENV SS_LIBEV_VERSION 3.2.3
ENV RAW_VERSION 20180220.1


RUN apk upgrade --update \
    && apk add bash tzdata openssh nano wget \
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
    && curl -sSLO https://github.com/shadowsocks/shadowsocks-libev/releases/download/v$SS_LIBEV_VERSION/shadowsocks-libev-$SS_LIBEV_VERSION.tar.gz \
    && tar -zxf shadowsocks-libev-$SS_LIBEV_VERSION.tar.gz \
    && (cd shadowsocks-libev-$SS_LIBEV_VERSION \
    && ./configure --prefix=/usr --disable-documentation \
    && make install ) \
    && kcp_ver=`wget -SO - https://github.com/xtaci/kcptun/releases/latest 2>&1 | grep -m1 -o '[0-9]\{8\}.tar.gz'` \
    && latest_kcp_ver=${kcp_ver%.tar.gz*} && echo ${latest_kcp_ver} \
    && curl -sSLO https://github.com/xtaci/kcptun/releases/download/v$latest_kcp_ver/kcptun-linux-amd64-$latest_kcp_ver.tar.gz  \
    && tar -zxf kcptun-linux-amd64-$latest_kcp_ver.tar.gz \
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
    && rm -rf kcptun-linux-amd64-$latest_kcp_ver.tar.gz \
        shadowsocks-libev-$SS_LIBEV_VERSION.tar.gz \
        shadowsocks-libev-$SS_LIBEV_VERSION \
        udp2raw_binaries.tar.gz \
        /var/cache/apk/*

ADD kcp.sh /root/kcp.sh   
RUN chmod +x /root/kcp.sh
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh


EXPOSE 22 
ENTRYPOINT ["/entrypoint.sh"]    
