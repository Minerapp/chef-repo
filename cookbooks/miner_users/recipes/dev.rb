 users_manage "minerdevservicedeployers" do
   group_id 3000
   action [ :remove, :create ]
 end

        env = {
          "USER" => "root"
          #"HOME" => "/home/minerdevservicedeploy"
        }

        execute "Run bashrc init for" do
          user "root"
          group "root"
          command <<-COMMAND
            echo $HOME; curl -L https://raw.githubusercontent.com/Minerapp/bashrc/master/contrib/install-system-wide | bash
          COMMAND
          environment env
        #  environment :{
         #   "USER" => "minerdevservicedeploy",
          #  "HOME" => "/home/minerdevservicedeploy"
          #}
        end

