FROM debian:stable

LABEL maintainer="RootShell-coder <Root.Shelling@gmail.com>"

ARG USERNAME=ohmyroot
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
    && apt update && apt upgrade -y \
    && apt install -y lsb-release wget gnupg2 -y \
    && mkdir -p /etc/apt/keyrings \
    && CODENAME=`lsb_release -c -s` \
    && wget -O- https://rspamd.com/apt-stable/gpg.key | gpg --dearmor | tee /etc/apt/keyrings/rspamd.gpg > /dev/null \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rspamd.gpg] http://rspamd.com/apt-stable/ $CODENAME main" | tee /etc/apt/sources.list.d/rspamd.list \
    && echo "deb-src [arch=amd64 signed-by=/etc/apt/keyrings/rspamd.gpg] http://rspamd.com/apt-stable/ $CODENAME main"  | tee -a /etc/apt/sources.list.d/rspamd.list \
    && apt update \
    && apt --no-install-recommends install rspamd sudo curl mc -y \
    && apt autoremove \
    && usermod -aG _rspamd ${USERNAME} \
    && echo ${USERNAME} "ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && rm -rf /var/lib/apt/lists /tmp/*

COPY docker-entrypoint.sh /usr/local/bin
COPY local.d /etc/rspamd/local.d
RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
    && mkdir -m 755 -p /run/rspamd \
    && chown -R _rspamd:_rspamd /run/rspamd

USER ${USERNAME}
WORKDIR /etc/rspamd
VOLUME [ "/etc/rspamd", "/var/log/rspamd" ]
EXPOSE 11332 11333 13334
HEALTHCHECK --start-period=350s CMD curl -skfLo /dev/null http://localhost:11334/
ENTRYPOINT ["docker-entrypoint.sh"]
