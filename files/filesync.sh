#! /bin/bash

/opt/puppetlabs/puppet/bin/curl -s --request POST --header "Content-Type: application/json" --data '{"commit-all": true}' --cert $(puppet config print hostcert) --key $(puppet config print hostprivkey) --cacert $(puppet config print cacert) https://localhost:8140/file-sync/v1/commit
