require 'albacore'
require File.expand_path("#{File.dirname(__FILE__)}/lib/build_type.rb")
require File.expand_path("#{File.dirname(__FILE__)}/lib/assembly_finder.rb")

TC_NUNIT_ENV_KEY  = 'nunitlauncher'
NUNIT_LAUNCHER = ENV[TC_NUNIT_ENV_KEY]

desc "Run tests by passing in test type and test environment (optional) e.g. ['Integration','systest']"
task :run_tests, :test_type, :test_env do |t, args|
	replace_test_config_files_for(args.test_type, args.test_env)
	run_tests(AssemblyFinder.new(SOLUTION).get_test_assemblies(args.test_type))
end

desc "Run unit tests"
task :run_unit_tests do 
    test_type = 'Unit'
	run_tests(AssemblyFinder.new(SOLUTION).get_test_assemblies(test_type))
end

desc "Run integration tests"
task :run_integration_tests, :test_env do |t, args|
	test_type = 'Integration'
	replace_test_config_files_for(test_type, args.test_env)
	run_tests(AssemblyFinder.new(SOLUTION).get_test_assemblies(test_type))
end

desc "Run acceptance tests"
task :run_acceptance_tests, :test_env do |t, args|
	test_type = 'Acceptance'
	replace_test_config_files_for(test_type, args.test_env)
	run_tests(AssemblyFinder.new(SOLUTION).get_test_assemblies(test_type))
end

desc "Run smokey tests"
task :run_smoke_tests, :test_env do |t, args|
	test_type = 'Smoke'
	replace_test_config_files_for(test_type, args.test_env)
	run_tests(AssemblyFinder.new(SOLUTION).get_test_assemblies(test_type))
end

desc "Run env tests"
task :run_environment_tests, :test_env do |t, args|
	test_type = 'Environment'
	replace_test_config_files_for(test_type, args.test_env)
	run_tests(AssemblyFinder.new(SOLUTION).get_test_assemblies(test_type))
end

desc "Run system tests"
task :run_system_tests, :test_env do |t, args|
	test_type = 'System'
	replace_test_config_files_for(test_type, args.test_env)
	run_tests(AssemblyFinder.new(SOLUTION).get_test_assemblies(test_type))
end

def run_tests(test_assemblies)
	nunit = Exec.new()
	require_nunit_launcher
	nunit.command = NUNIT_LAUNCHER

	add_nunit_launcher_params = ""
	puts NUNIT_LAUNCHER
	if NUNIT_LAUNCHER.include? "NUnitLauncher" 
		add_nunit_launcher_params = NUNIT_LAUNCHER_PARAMS
	end
	
	nunit.parameters << "#{add_nunit_launcher_params} #{test_assemblies.map {|assembly| "#{assembly} "}}" 
	nunit.execute
end

def replace_test_config_files_for(test_type, test_environment=nil)
	if (test_environment == nil || test_environment == "")
		raise "No test environment set"
	end
	
	puts "Replacing config files for#{test_environment}"
		
	build_type = BuildType.current_build_type
	puts "Build type: #{build_type}"
	
	test_config_files = Dir.glob("**/SevenDigital.**.#{test_type}.Tests.dll.config");
	
	if test_config_files.length == 0
		puts "Couldn't find any config files to replace"
	else
		test_config_files.each do |file|
			Dir.glob("**/app.#{test_environment}.config").each do |config|
				FileUtils.cp(config, file)
				puts "Copied #{config} to #{file}"
			end
		end
	end
end

def require_nunit_launcher
	raise "
		You need to set the <#{TC_NUNIT_ENV_KEY}> environment variable in order to run nunit.
		On Windows you can do that like this: 
			set #{TC_NUNIT_ENV_KEY}=\"path/to/JetBrains.BuildServer.NUnitLauncher.exe
		See: C:/BuildAgent/plugins/dotnetPlugin/bin/JetBrains.BuildServer.NUnitLauncher.exe
	"if NUNIT_LAUNCHER.nil?
end