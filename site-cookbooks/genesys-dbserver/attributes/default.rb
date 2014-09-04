default[:genesys_dbserver] = {
  :package => {
    :repository_name => "genesys_repo",
    :repo_base_url => "http://192.168.2.105/yum/x86_64",
    :rpm_name => "DBServer-ENU",
    :version => "8.1.300.05",
    :build_number => 1,
  },
  :service_name => "genesys-dbserver",
  :user => "genesys",
  :group => "genesys",
  :kill_wait_time => 10
}

default[:genesys][:home] = "/usr/local/genesys"

