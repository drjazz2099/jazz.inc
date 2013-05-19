require 'albacore'
require File.expand_path("#{File.dirname(__FILE__)}/lib/build_type.rb")

TC_LOGGER_ENV_KEY  = 'logger'
TC_LOGGER = "FileLogger,Microsoft.Build.Engine;logfile=MyLog.log"

desc "Build solution"
msbuild :build_solution, :warnings_as_errors do |msb, args|


#	require_logger
	path = getConfigurationFile("#{File.dirname(__FILE__)}/conf/", "msbuild.yml")
	puts "Build using config file: #{path}"
	msb.configure(File.expand_path(path))
	treat_warnings_as_errors = args[:warnings_as_errors] || true
	msb.properties :configuration => BuildType.current_build_type, :TreatWarningsAsErrors => treat_warnings_as_errors
	msb.targets :Clean, :Build
	#msb.loggermodule = "#{TC_LOGGER}" if TC_LOGGER != nil
	msb.solution = "#{SOLUTION}.sln"
end

def getConfigurationFile(conf_folder, yml_file)
	  
	  puts "finding defaults: #{yml_file}"
	  absolutePath = "#{conf_folder}/#{yml_file}"
	  unless File.exists?(absolutePath)
	    yml_file = "default_#{yml_file}"
		puts "no override found, falling back to #{yml_file}"
	    absolutePath = "#{conf_folder}/#{yml_file}"
	    fail("File does not exist: #{absolutePath}.") unless File.exists?(absolutePath)
	  end
	return absolutePath
end


def require_logger
	raise "
		You need to set the <#{TC_LOGGER_ENV_KEY}> environment variable in order to run msbuild.
		On Windows you can do that like this: 
			set #{TC_LOGGER_ENV_KEY}=\"path/to/JetBrains.BuildServer.MSBuildLoggers.MSBuildLogger
		If you see this error on the Build Server, please ensure the <#{TC_LOGGER_ENV_KEY}> environment variable has been set
		in the Build Agent config.
		If testing locally, set the environment variable to 'FileLogger,Microsoft.Build.Engine;logfile=MyLog.log'
	"if TC_LOGGER.nil?
end