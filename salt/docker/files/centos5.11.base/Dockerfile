FROM 10.64.5.169:5000/centos5.11

MAINTAINER songrunpeng songrunpeng@staff.cntv.cn

ADD src/ /tmp/src/
RUN chmod 755 -R /tmp/src; /tmp/src/setup.sh

EXPOSE 22

CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]
