# A container that acts like a VM for learning puppet
# This image is for training purposes and is not intended for production environments.
FROM phusion/baseimage
MAINTAINER Josh Samuelson <js@puppetlabs.com>
ENV HOME /root/
ENV TERM xterm
RUN curl https://apt.puppetlabs.com/puppetlabs-release-pc1-trusty.deb -o /tmp/puppetlabs-release-pc1-trusty.deb
RUN dpkg -i /tmp/puppetlabs-release-pc1-trusty.deb
RUN apt-get update
RUN apt-get install puppet-agent 
RUN ln -s /opt/puppetlabs/bin/puppet /usr/local/bin/puppet
ADD course_selector /tmp/course_selector
