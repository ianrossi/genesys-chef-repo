yum_repository node[:genesys_dbserver][:package][:repository_name] do
  description "Genesys Package Repo"
  baseurl node[:genesys_dbserver][:package][:repo_base_url]
  gpgcheck false
  action :create
end

execute "chown dbserver dir" do
  command "chown -R genesys:genesys /usr/local/genesys/dbserver-#{node[:genesys_dbserver][:package][:version]}"
  action :nothing
end

package node[:genesys_dbserver][:package][:rpm_name] do
  version "#{node[:genesys_dbserver][:package][:version]}-#{node[:genesys_dbserver][:package][:build_number]}"
  action :install
  notifies :run, resources(:execute => "chown dbserver dir"), :immediately
end

package "logrotate"

group "genesys" do
  gid "501"
end

user "genesys" do
  gid "genesys"
  uid "501"
  shell "/bin/bash"
  home "/usr/local/genesys"
  comment "User for all genesys applications"
end

# create a link to the 64bit executable for multiserver
link "#{node[:genesys][:home]}/dbserver-#{node[:genesys_dbserver][:package][:version]}/multiserver" do
  to "#{node[:genesys][:home]}/dbserver-#{node[:genesys_dbserver][:package][:version]}/multiserver_64"
  action :create
  owner "genesys"
  group "genesys"
  not_if "test -L #{node[:genesys][:home]}/dbserver-#{node[:genesys_dbserver][:package][:version]}/multiserver"
end

# create a link to the 64bit executable for postgres dbserver
link "#{node[:genesys][:home]}/dbserver-#{node[:genesys_dbserver][:package][:version]}/dbclient_postgre" do
  to "#{node[:genesys][:home]}/dbserver-#{node[:genesys_dbserver][:package][:version]}/dbclient_postgre_64"
  action :create
  owner "genesys"
  group "genesys"
  not_if "test -L #{node[:genesys][:home]}/dbserver-#{node[:genesys_dbserver][:package][:version]}/dbclient_postgre"
end

# create a link to the 64bit executable for oracle dbserver
link "#{node[:genesys][:home]}/dbserver-#{node[:genesys_dbserver][:package][:version]}/dbclient_oracle" do
  to "#{node[:genesys][:home]}/dbserver-#{node[:genesys_dbserver][:package][:version]}/dbclient_oracle_64"
  action :create
  owner "genesys"
  group "genesys"
  not_if "test -L #{node[:genesys][:home]}/dbserver-#{node[:genesys_dbserver][:package][:version]}/dbclient_oracle"
end

# dbserver.conf
template "#{node[:genesys][:home]}/dbserver-#{node[:genesys_dbserver][:package][:version]}/dbserver.conf" do
  source "dbserver.conf.erb"
  owner "genesys"
  group "genesys"
end

directory "/genesys/templates" do
  owner "genesys"
  group "genesys"
  mode 00644
  recursive true
  action :create
end

# template for cfg_env.py 
template "/genesys/templates/dbserver.tpl" do
  source "dbserver.tpl.erb"
  owner "genesys"
  group "genesys"
end

cookbook_file "/usr/local/bin/killtree.sh" do
  mode "0755"
end

directory "/var/log/#{node[:genesys_dbserver][:service_name]}" do
  owner "genesys"
  group "genesys"
  mode  "0775"
  recursive true
end

directory "/var/log/logrotate" do
  mode "0755"
  recursive true
end

template "/var/log/logrotate/#{node[:genesys_dbserver][:service_name]}.conf" do
  source "logrotate.conf.erb"
  mode "0644"
  owner "genesys"
  group "genesys"
  variables(
    :service => node[:genesys_dbserver][:service_name], 
    :log_location => "/var/log/#{node[:genesys_dbserver][:service_name]}", 
    :log_file => "#{node[:genesys_dbserver][:service_name]}.log"
  )
end

service "genesys-dbserver" do
  action :nothing
  supports :start => true, :enable => true, :restart => true, :status => true
end

template "/etc/init.d/#{node[:genesys_dbserver][:service_name]}" do
  source "initscript.erb"
  owner "genesys"
  group "genesys"
  mode "0755"
  variables(
    :user => "genesys",
    :log_location => "/var/log/#{node[:genesys_dbserver][:service_name]}",
    :log_file => "#{node[:genesys_dbserver][:service_name]}.log",
    :kill_wait_time => node[:genesys_dbserver][:kill_wait_time],
    :service_name => node[:genesys_dbserver][:service_name],
    :script_dir_location => "#{node[:genesys][:home]}/dbserver-#{node[:genesys_dbserver][:package][:version]}",
    :script_opts => "-host #{node[:fqdn]} -port 8888 -app cfg_dbserver",
    :script => "./multiserver"
  )
  notifies :restart, resources(:service => "genesys-dbserver"), :immediately
end

# service_base_script "genesys-dbserver" do
#   user "genesys"
#   script_dir_location "#{node[:genesys][:home]}/dbserver"
#   script "./multiserver"
#   script_opts "-host #{node[:fqdn]} -port 8888 -app cfg_dbserver"
# end
