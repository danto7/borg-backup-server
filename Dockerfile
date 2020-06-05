FROM alpine
RUN apk add openssh-server-pam openssh-sftp-server borgbackup --no-cache
ENV UID=1000 GID=1000
COPY ./sshd_config /etc/ssh/sshd_config
COPY ./entrypoint.sh /entrypoint.sh
ENTRYPOINT /entrypoint.sh
