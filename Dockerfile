FROM alpine:latest AS install_packages
ARG VERSION

LABEL maintainer="Pawel Rapkiewicz"
LABEL version=$VERSION

RUN apk add --update --no-cache openssh-server gnupg
RUN mkdir -p /host_keys.d

FROM install_packages AS add_user_bastion

RUN adduser -DH -s /sbin/nologin bastion
RUN mkdir -p /home/bastion/.ssh
RUN chown bastion:bastion /home/bastion/.ssh
RUN echo "bastion:$(echo $RANDOM | md5sum | cut -c-32)" | chpasswd

FROM add_user_bastion AS set_config_file

# Default environment variables
ENV SSHD_BIND=0.0.0.0
ENV SSHD_PORT=2022

COPY sshd_config /etc/ssh/sshd_config
COPY entrypoint.sh ./

EXPOSE 2022/tcp

ENTRYPOINT ["./entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D", "-e"]
