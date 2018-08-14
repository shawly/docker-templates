FROM siomiz/softethervpn:alpine

COPY run.sh /

RUN chmod +x /run.sh && \
    sed -i 's:-f /usr/vpnserver/vpn_server.config:-s /config/vpn_server.config:g' /entrypoint.sh && \
    mkdir -p /config && \
    touch /config/vpn_server.config && \
    touch /config/backup.vpn_server.config && \
    ln -s /config/vpn_server.config /usr/vpnserver/vpn_server.config && \
    ln -s /config/backup.vpn_server.config /usr/vpnserver/backup.vpn_server.config 

WORKDIR /config

VOLUME /config

ENTRYPOINT ["/run.sh"]

CMD ["/usr/bin/vpnserver", "execsvc"]
