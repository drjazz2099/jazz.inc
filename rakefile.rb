require 'albacore'
require 'rake'


BUILDTOOLS		= "C:/BuildTools"
GIT_BINARY = "#{BUILDTOOLS}/git/bin/git.exe"
SOLUTION		= 'jazz.inc'
TC_NUNIT_ENV_KEY  = 'nunitlauncher'
TC_NUNIT_LAUNCHER = ENV[TC_NUNIT_ENV_KEY]
TC_LOGGER_ENV_KEY  = 'logger'
#TC_LOGGER = ENV[TC_LOGGER_ENV_KEY]
TC_LOGGER  = "\"FileLogger,Microsoft.Build.Engine;logfile=MyLog.log\""
NUNIT_LAUNCHER_PARAMS = "v2.0 x86 NUnit-2.5.5"
DIRS_TO_PACKAGE = {}
require File.dirname(__FILE__) + '/build/nunit_test.rb'



desc "Build"
msbuild :build_solution do |msb|	
    require_logger
	msb.configure("build/conf/msbuild.yml")
	msb.properties = {:BuildType => :Release, :teamcity_projectName => "jazz.inc", :Configuration => :Release}
	msb.targets [:Build]
	msb.loggermodule = "#{TC_LOGGER}" if TC_LOGGER != nil
	msb.solution = "#{SOLUTION}.sln"
end




desc "Package precompiled web assets"
task :package do
	package_name = "#{SOLUTION}-distribution.zip"
	zd = ZipDirectory.new()
	dirs_to_package = ["src/*"]
	zd.directories_to_zip = dirs_to_package
	zd.output_file = package_name

	
	zip(zd)
end


def require_nunit_launcher
	raise "
		You need to set the <#{TC_NUNIT_ENV_KEY}> environment variable in order to run nunit.
		On Windows you can do that like this:
			set #{TC_NUNIT_ENV_KEY}=\"path/to/JetBrains.BuildServer.NUnitLauncher.exe
		See: C:/BuildAgent/plugins/dotnetPlugin/bin/JetBrains.BuildServer.NUnitLauncher.exe
	"if TC_NUNIT_LAUNCHER.nil?
raise "The executable <#{TC_NUNIT_LAUNCHER}> does not exist." unless File.exists?(TC_NUNIT_LAUNCHER)
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