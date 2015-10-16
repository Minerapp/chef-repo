 users_manage "minerdevservicedeployers" do
   group_id 3000
   action [ :remove, :create ]
 end

        env = {
          "USER" => "minerdevservicedeploy",
          "HOME" => "/home/minerdevservicedeploy",
        }

        execute "Run bashrc init for" do
          user "minerdevservicedeploy"
          group "minerdevservicedeploy" 
          command <<-COMMAND
            echo $HOME; curl -L https://raw.githubusercontent.com/Minerapp/bashrc/master/contrib/install-local | bash
          COMMAND
          environment env
        #  environment :{
         #   "USER" => "minerdevservicedeploy",
          #  "HOME" => "/home/minerdevservicedeploy"
          #}
        end

