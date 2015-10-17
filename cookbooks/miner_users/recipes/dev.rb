node.default['authorization']['sudo']['passwordless'] = true
node.default['authorization']['sudo']['groups'] = ["minerops", "sysadmin", "wheel", "admin"]
node.default['authorization']['sudo']['include_sudoers_d'] = true

 users_manage "minerdevservicedeployers" do
   group_id 3000
   action [ :remove, :create ]
 end

 users_manage "minerdevdatabaseadmins" do
   group_id 3001
   action [ :remove, :create ]
 end

### Create core system-wide bashrc
env = {
  "USER" => "root"
}

execute "Run bashrc init for" do
  user "root"
  group "root"
  command <<-COMMAND
    echo $HOME; curl -L https://raw.githubusercontent.com/Minerapp/bashrc/master/contrib/install-system-wide | bash
  COMMAND
  environment env
end


sudo 'minerdevservicedeployers' do
  group     "%minerdevservicedeployers"    # or a username
  nopasswd true
  commands ['/usr/local/bin/pm2', '/bin/echo']
  env_keep_add ['PM2_HOME', 'NODE_ENV']
end