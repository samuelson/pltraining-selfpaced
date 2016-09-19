Module for installing Puppetlabs self-paced training environment

This module sets up an nginx server, docker, web-based terminal, and supporting scripts for the self-paced training exercises.

It should be installed on a Puppet Enterprise Master which has autosigning enabled and filesync disabled.

LXD:

The lxd backend requires a bit of manual setup:
1. Spin up an ubuntu 14.04 instance
1. Change hostname to try.puppet.com
1. Install PE
1. add `autosign=true` to puppet.conf
1. Add the pe_repo module for el7
`pe_repo::platform::el_7_x86_64`
1. Copy up the cert and key
1. Add the lxd ppa as described here: https://linuxcontainers.org/lxd/getting-started-cli/
1. In the PE console group set "console_ssl_listen_port" = 8443
1. Classify with the selfpaced module and run puppet
1. Set up lxd bridge with IPv4, NAT, and domain=try.puppet.com
  `lxd init`
1. Build base container:
  1. `lxc launch images:centos/7/amd64 agent-base`
  1. `lxc exec agent-base -- init 3`
  1. `lxc exec agent-base -- bash`
  1.`rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm`
  1. `yum install -y puppet-agent cronie`
  1. add `[agent]` and `server=try.puppet.com` to puppet.conf
  1. hit ctrl-d to exit back to host OS
1. Build a new image from the base container (note: this takes a while):
  `lxc publish agent-base --alias agent --force`
1. Bump up the number of allowed open files:
 `sysctl -w fs.inotify.max_user_instances=8192`
