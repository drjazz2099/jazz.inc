$: << "#{File.expand_path(File.dirname(__FILE__))}\\..\\ir_lib\\external"
Dir["#{File.dirname(__FILE__)}/../ir_lib/**/*.rb"].each {|file| require file }
project_name = ARGV[0]
env = ARGV[1]
source_version = ARGV[2]
target_version = ARGV[3]

IIS_CONF = "#{File.expand_path(File.dirname(__FILE__))}/../conf/iis.yml"

# setup an iis_deployment_setup instance
iis_deployment_setup = IISDeploymentSetup.new(project_name,source_version, 0)
iis_deployment_setup.configure(IIS_CONF, env) 

# sets the virtual directory to_version, to point to the directory of version
swap = IISSwap.new() 
swap.run(iis_deployment_setup, source_version, target_version)
