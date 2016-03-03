Module for installing Puppetlabs self-paced training environment

This module sets up an nginx server, docker, web-baseed terminal, and supporting scripts for the self-paced training exercises.

It should be installed on a Puppet Enterprise Master which has autosigning enabled and filesync disabled.

Note: The initial puppet run takes a _very_ long time because of NPM/NodeJS compiling from source
