# FROM alpine:3.12.1
FROM alpine:3.13.2

ARG timezone=Europe/Zurich
ARG user=ansible
ARG group=ansible
ARG uid=1001
ARG gid=1001
ARG ANSIBLE_VERSION=2.9.15
ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1

RUN \
apk update && \
apk upgrade && \
rm -rf /var/cache/apk/* && \
# Add build libs
apk add --no-cache --virtual build-dependencies \
git \
gcc \
build-base \
bash-completion \
bash \
util-linux \
openssh \
fping \
curl \
autossh \
mc \
libc-dev \
libffi-dev \
make \
python3-dev \
tzdata && \
# Create user
addgroup -g ${gid} ${user} && \
adduser -u ${uid} -G ${group} -s /bin/bash -D ${user} && \
# Set timezone
cp /usr/share/zoneinfo/$timezone /etc/localtime && \
echo $timezone > /etc/timezone && \
# Add runtime libs
apk add --no-cache \
# Common libs
bash \
bind-tools \
ca-certificates \
# LDAP libs
openldap-clients \
# Python libs
python3 \
py3-pip \
# SSL
openssh-client \
libressl-dev && \
# Set Python3 as default Python interpreter
if [ ! -e /usr/bin/pip ]; then ln -s /usr/bin/pip3 /usr/bin/pip ; fi && \
if [ ! -e /usr/bin/python ]; then ln -s /usr/bin/python3 /usr/bin/python; fi

## Install Ansible & modules
RUN \
## Ansible
pip install --upgrade pip setuptools && \
pip install cffi && \
pip install ansible==${ANSIBLE_VERSION} simplejson jmespath && \
# Network
pip install dnspython netaddr && \
# SSL - for ansible openssl_csr module
pip install pyOpenSSL && \
pip install pyvim && \
pip install PyVmomi && \
pip install pywinrm && \
apk del build-dependencies && \
rm -rf /var/cache/apk/* && \
rm -rf /root/.cache

ENV \
DISTRIBUTION=alpine \
ANSIBLE_VERSION=${ANSIBLE_VERSION} \

WORKDIR /root/lab

RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh && mkdir /etc/ansible

COPY common/ansible.cfg /etc/ansible/ansible.cfg
COPY common/ansible.cfg.optimized /etc/ansible/ansible.cfg.optimized

COPY ["common/id_rsa", "common/id_rsa.pub", "/root/.ssh/"]

RUN chmod 644 /root/.ssh/id_rsa.pub && chmod 600 /root/.ssh/id_rsa

ENTRYPOINT ["/bin/bash"]
