FROM alpine:3.7

LABEL maintainer="mritd <mritd1234@gmail.com>"

ARG TZ="Asia/Shanghai"

ENV TZ ${TZ}
ENV SERVER_IP 127.0.0.1
ENV KCP_SERVER_PORT 26817


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
    && apk add --virtual curl \
        tar \
        git \
    && kcp_ver=`wget -SO - https://github.com/xtaci/kcptun/releases/latest 2>&1 | grep -m1 -o '[0-9]\{8\}.tar.gz'` \
    && latest_kcp_ver=${kcp_ver%.tar.gz*} && echo ${latest_kcp_ver} \
    && curl -sSLO https://github.com/xtaci/kcptun/releases/download/v$latest_kcp_ver/kcptun-linux-amd64-$latest_kcp_ver.tar.gz  \
    && tar -zxf kcptun-linux-amd64-$latest_kcp_ver.tar.gz \
    && mv server_linux_amd64 /usr/bin/kcpserver \
    && mv client_linux_amd64 /usr/bin/kcpclient \
    && ln -sf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && rm -rf kcptun-linux-amd64-$KCP_VERSION.tar.gz \
        /var/cache/apk/*

ADD kcp.sh /root/kcp.sh   
RUN chmod +x /root/kcp.sh
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh


EXPOSE 8964
ENTRYPOINT ["/entrypoint.sh"]    
