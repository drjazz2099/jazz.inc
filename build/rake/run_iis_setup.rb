$: << "#{File.expand_path(File.dirname(__FILE__))}\\..\\ir_lib\\external"
Dir["#{File.dirname(__FILE__)}/../ir_lib/**/*.rb"].each {|file| require file }
project_name = ARGV[0]
env = ARGV[1]
build_number = ARGV[2]
version = ARGV[3]

IIS_CONF = "#{File.expand_path(File.dirname(__FILE__))}/../conf/iis.yml"

# setup an iis_deployment_setup instance
iis_deployment_setup = IISDeploymentSetup.new(project_name, version, build_number)
iis_deployment_setup.configure(IIS_CONF, env) 

unless File.exists?(iis_deployment_setup.path) && File.directory?(iis_deployment_setup.path)
	puts "Creating website path: #{iis_deployment_setup.path}"
	Dir.mkdir iis_deployment_setup.path
end
	
# setp an iissetup instance and give it an iis_deployment_setup
setup = IISSetup.new() 
setup.run(iis_deployment_setup)
