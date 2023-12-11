FROM registry.openanolis.cn/openanolis/anolisos:23

RUN dnf -y install rpm-build 'dnf-command(config-manager)'