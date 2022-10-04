FROM registry.access.redhat.com/ubi9/ubi
LABEL maintainer="DSV UBI9 based Postgress Image Builder"

LABEL com.redhat.component="ubi9-init-container"
LABEL com.redhat.license_terms="https://www.redhat.com/en/about/red-hat-end-user-license-agreements#UBI"
LABEL name="ubi9/ubi9-init"
LABEL version="9.0.0"

LABEL summary="Provides the latest release of the Red Hat Universal Base Image 9 Init for multi-service containers."
LABEL description="The Universal Base Image Init is designed is designed to run an init system as PID 1 for running multi-services inside a container. This base image is freely redistributable, but Red Hat only supports Red Hat technologies through subscriptions for Red Hat products. This image is maintained by Red Hat and updated regularly."
LABEL io.k8s.display-name="Red Hat Universal Base Image 9 Init"
LABEL io.openshift.expose-services=""
LABEL usage="Do not use directly. Use as a base image for daemons. Install chosen packages and 'systemctl enable' them."

STOPSIGNAL SIGRTMIN+3

#mask systemd-machine-id-commit.service - partial fix for https://bugzilla.redhat.com/show_bug.cgi?id=1472439
RUN systemctl mask systemd-remount-fs.service dev-hugepages.mount sys-fs-fuse-connections.mount systemd-logind.service getty.target console-getty.service systemd-udev-trigger.service systemd-udevd.service systemd-random-seed.service systemd-machine-id-commit.service

RUN dnf -y update; dnf -y install procps-ng sudo postgresql && dnf clean all

ENV ca_cert_dir /etc/rhsm/ca/

ADD ./postgresql-setup /usr/bin/postgresql-setup
ADD ./start_postgres.sh /start_postgres.sh
ADD ./redhat.sh /Red_Hat_Product_Certificates.sh

RUN chmod +x /Red_Hat_Product_Certificates.sh
RUN ./Red_Hat_Product_Certificates.sh

RUN SMDEV_CONTAINER_OFF=1 subscription-manager register --org=15517660 --activationkey=rhel-containerbuild && \
    dnf install -y postgresql-server postgresql-contrib && \
    SMDEV_CONTAINER_OFF=1 subscription-manager unregister && \
    dnf clean all && \
    echo -e '[main]\nenabled=0' >  /etc/yum/pluginconf.d/subscription-manager.conf

#Sudo requires a tty. fix that.
RUN sed -i 's/.*requiretty$/#Defaults requiretty/' /etc/sudoers
#RUN chmod +x /usr/bin/postgresql-setup
#RUN chmod +x /start_postgres.sh

#RUN /usr/bin/postgresql-setup initdb

#ADD ./postgresql.conf /var/lib/pgsql/data/postgresql.conf

#RUN chown -v postgres.postgres /var/lib/pgsql/data/postgresql.conf

#RUN echo "host    all             all             0.0.0.0/0               md5" >> /var/lib/pgsql/data/pg_hba.conf

#VOLUME ["/var/lib/pgsql"]

#EXPOSE 5432

##CMD ["/bin/bash", "/start_postgres.sh"]
CMD ["/sbin/init"]
