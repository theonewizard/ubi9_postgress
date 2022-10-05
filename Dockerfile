FROM registry.access.redhat.com/ubi9/ubi:latest
LABEL maintainer="DSV UBI9 based Image"

LABEL com.redhat.component="ubi9-init-container"
LABEL com.redhat.license_terms="https://www.redhat.com/en/about/red-hat-end-user-license-agreements#UBI"
LABEL name="DSV/ubi9-base"
LABEL version="9.0.1"

LABEL summary="Provides the latest release of the Red Hat Universal Base Image 9 Init for multi-service containers."
LABEL description="The Universal Base Image Init is designed is designed to run an init system as PID 1 for running multi-services inside a container. This base image is freely redistributable, but Red Hat only supports Red Hat technologies through subscriptions for Red Hat products. This image is maintained by Red Hat and updated regularly."
LABEL io.k8s.display-name="DSV Red Hat Universal Base Image 9 Init"
LABEL io.openshift.expose-services=""
LABEL usage="Do not use directly. Use as a base image for daemons. Install chosen packages and 'systemctl enable' them."

STOPSIGNAL SIGRTMIN+3

#mask systemd-machine-id-commit.service - partial fix for https://bugzilla.redhat.com/show_bug.cgi?id=1472439
RUN systemctl mask systemd-remount-fs.service dev-hugepages.mount sys-fs-fuse-connections.mount systemd-logind.service getty.target console-getty.service systemd-udev-trigger.service systemd-udevd.service systemd-random-seed.service systemd-machine-id-commit.service

ADD ./postgresql-setup /postgresql-setup
RUN chmod +x /postgresql-setup

RUN dnf -y update && \
    dnf install -y openssh-server procps-ng sudo && \
    dnf clean all && \
    rpm -Uvh https://repo.nagios.com/nagios/9/nagios-repo-9-1.el9.noarch.rpm && \
    echo "testing Jakob" && \
    sed -i 's/.*requiretty$/#Defaults requiretty/' /etc/sudoers

CMD ["/sbin/init"]