# A container that acts like a VM for learning puppet
# This image is for training purposes and is not intended for production environments.
FROM centos:7
MAINTAINER Josh Samuelson <js@puppetlabs.com>
ENV HOME /root/
ENV TERM xterm
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/puppet/bin
RUN yum -y install  tar dmidecode which logrotate cyrus-sasl libxslt cronie pciutils git rubygems vim tree csh zsh net-tools wget redhat-logos
RUN gem install multipart-post -v 1.2.0
RUN rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
RUN yum -y install puppet-agent
RUN echo "172.17.0.1 puppet" >> /etc/hosts; puppet agent -t; exit 0
RUN rm -rf /etc/puppetlabs/puppet/ssl/*
CMD ["/sbin/init"]
