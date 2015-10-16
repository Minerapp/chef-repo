 users_manage "minerprodservicedeployers" do
   group_id 3000
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

