

package node[:genesys_dbserver][:package][:rpm_name] do
  version "#{node[:genesys_dbserver][:package][:version]}-#{node[:genesys_dbserver][:package][:build_number]}"
  action :install
end

# create a link to the 64bit executable for multiserver
link "#{node[:genesys][:home]}/dbserver/multiserver" do
	to "#{node[:genesys][:home]}/dbserver/multiserver_64"
	action :create
	owner "genesys"
	group "genesys"
	not_if "test -L #{node[:genesys][:home]}/dbserver/multiserver"
end

# create a link to the 64bit executable for postgres dbserver
link "#{node[:genesys][:home]}/dbserver/dbclient_postgre" do
	to "#{node[:genesys][:home]}/dbserver/dbclient_postgre_64"
	action :create
	owner "genesys"
	group "genesys"
	not_if "test -L #{node[:genesys][:home]}/dbserver/dbclient_postgre"
end

# create a link to the 64bit executable for oracle dbserver
link "#{node[:genesys][:home]}/dbserver/dbclient_oracle" do
	to "#{node[:genesys][:home]}/dbserver/dbclient_oracle_64"
	action :create
	owner "genesys"
	group "genesys"
	not_if "test -L #{node[:genesys][:home]}/dbserver/dbclient_oracle"
end

# dbserver.conf
template "#{node[:genesys][:home]}/dbserver/dbserver.conf" do
	source "dbserver.conf.erb"
	owner "genesys"
	group "genesys"
end

# template for cfg_env.py 
template "/genesys/templates/dbserver.tpl" do
	source "tpl/dbserver.tpl.erb"
	owner "genesys"
	group "genesys"
end

service_base_script "genesys-dbserver" do
	user "genesys"
	script_dir_location "#{node[:genesys][:home]}/dbserver"
	script "./multiserver"
	script_opts "-host #{node[:fqdn]} -port 8888 -app cfg_dbserver"
end
