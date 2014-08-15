search("node","platform:centos").each do |server|
  log "Then CentOS servers in your organization have the following FQDN/IP Addresses:- #{server["fqdn"]}/#{server["ipaddress"]}"
end
