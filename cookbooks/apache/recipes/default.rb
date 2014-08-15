#
# Cookbook Name:: apache
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
# priority - Ohai, role, environment, recipe, attribute file

package "httpd" do
  action :install
end

# disable the default virtualhost
execute "mv /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/welcome.conf.disabled" do
  only_if do
    File.exist?("/etc/httpd/conf.d/welcome.conf")
  end
  notifies :restart, "service[httpd]"
end

# iterate over the apache sites
node["apache"]["sites"].each do |site_name, site_data|
  # set document root
  document_root = "/srv/apache/#{site_name}"

  # template for apache virtual host configs
  template "/etc/httpd/conf.d/#{site_name}.conf" do
    source "custom.erb"
    mode "0644"
    variables(:document_root => document_root,:port => site_data["port"])
    notifies :restart, "service[httpd]"
  end

  # add a directory resource to create the document root
  directory document_root do
    mode "0755"
    recursive true
  end

  template "#{document_root}/index.html" do
    source "index.html.erb"
    mode "0644"
    variables(:site_name => site_name, :port => site_data["port"])
  end
end

service "httpd" do
  action [ :enable, :start ]
end

#node.default["apache"]["indexfile"] = "index2.html"

#cookbook_file "/var/www/html/index.html" do
#  source node["apache"]["indexfile"]
#  mode "0644"
#end
