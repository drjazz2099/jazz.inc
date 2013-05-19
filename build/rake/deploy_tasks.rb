Dir["#{File.dirname(__FILE__)}/../lib/**/*.rb"].each {|file| require file }
require "rake"
require "net/ftp"
require "yaml"

SSH_KEY_REG_FILE	 = 'C:/TeamCityBuildTools/DeploymentKeyConfig/KeyRegistration.reg'
CONF				 = "#{File.dirname(__FILE__)}/../conf"
DEPLOY_CONF			 = "deploy.yml"
FTP_CONF			 = "ftp.yml"
MIGRATIONS_CONF		 = "migrations.yml"
SERVERS_CONF		 = "servers.yml"
DEPLOYMENT_INFO_CONF = "deployment_copy.yml"


desc "deploys the current branch, gets the version to deploy from version.txt"
task :deploy_release, :environment, :servers, :build_number do |t, args|
server_list = args.servers.split(';')

	puts "Deploying to (#{server_list.length}) server(s)."

	server_list.each do |server|
		run_task("deploy_to",
			:server => server,
			:environment => args.environment
		)
        run_task(
			"boot_strap_post_deploy",
			:server 		=> server,
			:environment 	=> args.environment,
			:version 		=> get_version,
			:build_number	=> args.build_number
		)
	end
end


desc "Deploys something to a list of remote computers"
task :deploy, :environment, :version, :servers, :build_number, :force_create do |t, args|

	server_list = args.servers.split(';')
	
	puts "Deploying to (#{server_list.length}) server(s)."
	
	server_list.each do |server|
		run_task("deploy_to", 
			:server => server, 
			:environment => args.environment
		)
        run_task(
			"boot_strap_post_deploy", 
			:server 		=> server, 
			:environment 	=> args.environment, 
			:version 		=> args.version,
			:build_number	=> args.build_number,
			:force_create	=> args.force_create
		)
	end
end

desc "Deploys to your local machine using the local environment"
task  :post_deploy_local do 
	puts "Deploying to your local machine."
	
	run_task(
			"post_deploy", 
			:server 		=> "localhost", 
			:environment 	=> "local", 
			:version 		=> "1.0",
			:build_number   => "1"
		)
end

desc "Deploys something to a single remote computer"
task :deploy_to, :server, :environment do |t, args|
	puts "Deploying to <#{args[:server]}>"

	server_info = get_server_info(args[:environment], args[:server])
	ftp_info = get_ftp_info(args[:environment])

	Deploy.new(server_info, ftp_info, Net::FTP.new, SimpleLog.new) do |dep|
		dep.configure(CONF, DEPLOY_CONF)
	
		puts "Deploying <#{dep.package}>"
		
		dep.deploy()
	end
end

desc "Bootstraps a deployment on a remote computer"
task :boot_strap_post_deploy, :server, :environment, :version, :build_number, :force_create do |t, args|
	run_task("add_ssh_keys")
	
	puts "Starting bootstrap"
	
	deployment_info = get_deployment_info(args[:environment])
	
	BootStrapDeploy.new(deployment_info) do |bootstrap|
		bootstrap.run(args[:server], args[:environment], args[:version], args[:build_number], args[:force_create])
	end
end

desc "Runs post deploy script on a list of remote computers"
task :post_deploy, :server, :environment, :version, :build_number, :force_create  do |t, args|
	puts "Starting post deploy #{args}"
	
	if args[:force_create] == nil
		args[:force_create] = false
	end
	
	puts "Force create: #{args[:force_create]}"
	
	deployment_info = get_deployment_info(args[:environment])
	
	PostDeploy.new(deployment_info) do |post_deploy|
		post_deploy.run(args[:server], args[:environment], args[:version], args[:build_number], args[:force_create])
	end
end

desc "Swaps the project's IIS virtual directories"
task :swap_version, :server, :environment, :target_version do |t, args|
	puts "Deploying to <#{args[:server]}>"

	server_info = get_server_info(args[:environment], args[:server])
	ftp_info = get_ftp_info(args[:environment])

	Deploy.new(server_info, ftp_info, Net::FTP.new, SimpleLog.new) do |dep|
		dep.configure(CONF, DEPLOY_CONF)
		puts "Deploying <#{dep.package}>"
		dep.deploy()
	end
	puts "starting swap"
	deployment_info = get_deployment_info(args[:environment])
	BootStrapSwapVersion.new(deployment_info) do |swap_version|
		swap_version.run(args[:server], args[:environment], get_version, args[:target_version])
	end
end

desc "Registers the current machine with SSH keypair"
task :add_ssh_keys do
	puts "Registering SSH keys"
	%x{reg import #{SSH_KEY_REG_FILE}}
end

private 
def run_task (name, args = nil)
	Rake::Task[name].execute(args) 
end

def get_ftp_info(environment)
	ftp_info = FtpInfo.new()
	ftp_info.configure(CONF, FTP_CONF, environment)
	ftp_info
end

def get_server_info(environment, server)
	server_info = ServerInfo.new(server)
	server_info.configure(CONF, SERVERS_CONF, environment)
	server_info
end

def get_deployment_info(environment)
	deployment_info = DeploymentInfo.new()
	deployment_info.configure(CONF, DEPLOYMENT_INFO_CONF, environment)
	deployment_info
end

def get_version
	File.open("version.txt") {|f| f.readline}
end
