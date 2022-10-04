FROM registry.access.redhat.com/ubi8/ubi
LABEL maintainer="DSV UBI8 based Postgress Image Builder"

LABEL com.redhat.component="ubi8-base-container"
LABEL com.redhat.license_terms="https://www.redhat.com/en/about/red-hat-end-user-license-agreements#UBI"
LABEL name="ubi8/ubi8-postgress"
LABEL version="9.0.0"

LABEL io.k8s.display-name="DSV Base Image Container"
LABEL io.openshift.expose-services=""

STOPSIGNAL SIGRTMIN+3

#mask systemd-machine-id-commit.service - partial fix for https://bugzilla.redhat.com/show_bug.cgi?id=1472439
RUN systemctl mask systemd-remount-fs.service dev-hugepages.mount sys-fs-fuse-connections.mount systemd-logind.service getty.target console-getty.service systemd-udev-trigger.service systemd-udevd.service systemd-random-seed.service systemd-machine-id-commit.service

RUN yum -y update; yum -y install procps-ng sudo postgresql && yum clean all

ADD ./postgresql-setup /usr/bin/postgresql-setup
ADD ./start_postgres.sh /start_postgres.sh

RUN SMDEV_CONTAINER_OFF=1 subscription-manager register --org=15517660 --activationkey=rhel-containerbuild && \
    yum install -y postgresql-server postgresql-contrib && \
    SMDEV_CONTAINER_OFF=1 subscription-manager unregister && \
    yum clean all && \
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
