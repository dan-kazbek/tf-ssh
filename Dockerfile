ARG BASE_IMAGE=tensorflow/tensorflow:2.17.0-gpu

FROM $BASE_IMAGE

LABEL org.opencontainers.image.authors="Daniyar Kazbek"
LABEL org.opencontainers.image.source="https://github.com/dan-kazbek/tf-ssh"

# all the additional packages to install must be listed here
RUN set -ex; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        vim ffmpeg libsm6 libxext6 sudo git wget unzip graphviz screen xauth python3-tk;\
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    python3 -m pip install --upgrade pip;

ENV OPENSSH_PORT=22 \
    OPENSSH_ROOT_PASSWORD="" \
    OPENSSH_ROOT_AUTHORIZED_KEYS="" \
    OPENSSH_USER="ssh" \
    OPENSSH_USERID=1001 \
    OPENSSH_GROUP="ssh" \
    OPENSSH_GROUPID=1001 \
    OPENSSH_PASSWORD="" \
    OPENSSH_AUTHORIZED_KEYS="" \
    OPENSSH_HOME="/home/ssh" \
    OPENSSH_SHELL="/bin/bash" \
    OPENSSH_RUN="" \
    OPENSSH_ALLOW_TCP_FORWARDING="all"

# install GnuPG if not already installed
RUN set -ex; \
    if ! command -v gpg > /dev/null; then \
        export DEBIAN_FRONTEND=noninteractive; \
        apt-get update; \
        apt-get install -y --no-install-recommends \
            gnupg \
            dirmngr \
        ; \
        rm -rf /var/lib/apt/lists/*; \
    fi

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      openssh-server rsync augeas-tools; \
    chmod +x /usr/local/bin/entrypoint.sh; \
    rm -f /etc/motd; \
    passwd -d root; \
    mkdir -p ~root/.ssh /etc/authorized_keys; \
    printf 'set /files/etc/ssh/sshd_config/AuthorizedKeysFile ".ssh/authorized_keys /etc/authorized_keys/%%u"\n'\
'set /files/etc/ssh/sshd_config/ClientAliveInterval 30\n'\
'set /files/etc/ssh/sshd_config/ClientAliveCountMax 5\n'\
'set /files/etc/ssh/sshd_config/PermitRootLogin yes\n'\
'set /files/etc/ssh/sshd_config/PasswordAuthentication yes\n'\
'set /files/etc/ssh/sshd_config/Port 22\n'\
'set /files/etc/ssh/sshd_config/AllowTcpForwarding no\n'\
'set /files/etc/ssh/sshd_config/Match[1]/Condition/Group "wheel"\n'\
'set /files/etc/ssh/sshd_config/Match[1]/Settings/AllowTcpForwarding yes\n'\
'save\n'\
'quit\n' | augtool; \
    cp -a /etc/ssh /etc/ssh.cache; \
    apt-get remove -y augeas-tools; \
    rm -rf /var/lib/apt/lists/*;

# create new user and start ssh server
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
