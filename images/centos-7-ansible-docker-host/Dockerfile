#FROM centos:7
FROM centos/python-35-centos7:latest
USER root

ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in ; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done);
RUN rm -rf /lib/systemd/system/multi-user.target.wants/ \
    && rm -rf /etc/systemd/system/.wants/ \
    && rm -rf /lib/systemd/system/local-fs.target.wants/ \
    && rm -f /lib/systemd/system/sockets.target.wants/udev \
    && rm -f /lib/systemd/system/sockets.target.wants/initctl \
    && rm -rf /lib/systemd/system/basic.target.wants/ \
    && rm -f /lib/systemd/system/anaconda.target.wants/*
VOLUME [ "/sys/fs/cgroup" ]

RUN yum install -y openssh-server
RUN mkdir ~/.ssh && ssh-keygen -N "" -t rsa -f ~/.ssh/id_rsa && yum install -y initscripts

COPY common/id_rsa.pub /root/.ssh/authorized_keys
#COPY common/start.sh /start.sh

RUN test -f /etc/ssh/ssh_host_ecdsa_key || /usr/bin/ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -C '' -N ''
RUN test -f /etc/ssh/ssh_host_rsa_key || /usr/bin/ssh-keygen -q -t rsa -f /etc/ssh/ssh_host_rsa_key -C '' -N ''
RUN test -f /etc/ssh/ssh_host_ed25519_key || /usr/bin/ssh-keygen -q -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -C '' -N ''
RUN sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
#RUN /usr/sbin/sshd -D
WORKDIR /root
ENV ALLOW_EXIT true
CMD ["/usr/sbin/init"]

