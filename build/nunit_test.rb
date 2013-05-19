require 'albacore'
require File.expand_path("#{File.dirname(__FILE__)}/lib/build_type.rb")
require File.expand_path("#{File.dirname(__FILE__)}/lib/assembly_finder.rb")

TC_NUNIT_ENV_KEY  = 'nunitlauncher'
NUNIT_LAUNCHER = "FileLogger,Microsoft.Build.Engine;logfile=MyLog.log"

TC_NUNIT_LAUNCHER = ENV[TC_NUNIT_ENV_KEY]
TC_LOGGER_ENV_KEY  = 'logger'
TC_LOGGER = ENV[TC_LOGGER_ENV_KEY]

NUNIT_LAUNCHER_PARAMS = "v2.0 x86 NUnit-2.5.5"

desc 'Configure the application for a specific environment'
task :reconfigure_tests do
	environment = ENV['env']
	replace_test_config_files_for environment
end

desc "Run tests by passing in test type and test environment (optional) e.g. ['Integration','systest']"
task :run_tests, :test_type, :test_env do |t, args|
	
	run_tests(AssemblyFinder.new(SOLUTION).get_test_assemblies(args.test_type))
end

desc "Run unit tests"
task :run_unit_tests do 
    test_type = 'Unit'
	run_tests(AssemblyFinder.new(SOLUTION).get_test_assemblies(test_type))
end

desc "Run integration tests"
task :run_integration_tests, :test_env do |t, args|
	test_type = 'IntegrationTests'
	run_tests(AssemblyFinder.new(SOLUTION).get_test_assemblies(test_type))
end

desc "Run database tests"
task :run_database_tests, :test_env do |t, args|
	run_tests(AssemblyFinder.new(SOLUTION).get_assemblies('Sunshine.DB.Tests'))
end


desc "Run Specs"
task :run_spec_flow, :test_env, :ignore do |t, args|
	test_type = 'Spec'
	
	args.each do |x|
		puts x
		end
	puts ("environment : #{args.test_env}")
	puts ("ignore categories : #{args.ignore}")

	root = Dir.pwd
	
	Dir['dependencies/*'].each do |test_dir|
		Dir.chdir test_dir do
			token_replacer = TokenReplacer.new args.test_env, File.join(root, 'global.tokens')
			
			binaries_dir = Dir['**/bin/Release'].first
		
			config_file = Dir["#{binaries_dir}/*.dll.config"].first
			puts "Binaries are in #{binaries_dir}, config is #{config_file}"
			token_replacer.replace_file_matching(binaries_dir, config_file, config_file.gsub(/[\w\.]+$/, 'app.config'))
		end
	end
	run_specs(AssemblyFinder.new(SOLUTION).get_test_assemblies(test_type),args.ignore)
end

desc "Run Specs"
task :run_spec_flow_for_smokes, :test_env do |t, args|
	test_type = 'Spec'
	puts ("environment : #{args.test_env}")

	root = Dir.pwd
	
	Dir['dependencies/*'].each do |test_dir|
		Dir.chdir test_dir do
			token_replacer = TokenReplacer.new args.test_env, File.join(root, 'global.tokens')
			
			binaries_dir = Dir['**/bin/Release'].first
		
			config_file = Dir["#{binaries_dir}/*.dll.config"].first
			puts "Binaries are in #{binaries_dir}, config is #{config_file}"
			token_replacer.replace_file_matching(binaries_dir, config_file, config_file.gsub(/[\w\.]+$/, 'app.config'))
		end
	end
	run_specs_for_smoke(AssemblyFinder.new(SOLUTION).get_test_assemblies(test_type))
end

desc "Run Specs"
task :run_spec_flow_for_roger, :test_env do |t, args|
	test_type = 'Spec'
	puts ("environment : #{args.test_env}")

	root = Dir.pwd
	
	Dir['dependencies/*'].each do |test_dir|
		Dir.chdir test_dir do
			token_replacer = TokenReplacer.new args.test_env, File.join(root, 'global.tokens')
			
			binaries_dir = Dir['**/bin/Release'].first
		
			config_file = Dir["#{binaries_dir}/*.dll.config"].first
			puts "Binaries are in #{binaries_dir}, config is #{config_file}"
			token_replacer.replace_file_matching(binaries_dir, config_file, config_file.gsub(/[\w\.]+$/, 'app.config'))
		end
	end

	run_specs_for_roger(AssemblyFinder.new(SOLUTION).get_test_assemblies(test_type))
end


desc "Run Specs TeamCity"
task :run_tests_team_city, :test_env do |t, args|
	test_type = 'Spec'
	puts ("environment : #{args.test_env}")

	replace_test_config_files_for(args.test_env)	
	run_tests(AssemblyFinder.new(SOLUTION).get_test_assemblies(test_type))
end

desc "New task that actually works with reconfiguration to run Specs TeamCity by category"
task :new_run_tests_team_city, :test_env do |t, args|
	test_type = 'Spec'
	
	root = Dir.pwd
	
	Dir['dependencies/*'].each do |test_dir|
		Dir.chdir test_dir do
			token_replacer = TokenReplacer.new args.test_env, File.join(root, 'global.tokens')
			
			binaries_dir = Dir['**/Release'].first
		
			config_file = Dir["#{binaries_dir}/*.dll.config"].first
			puts "Binaries are in #{binaries_dir}, config is #{config_file}"
			token_replacer.replace_file_matching(binaries_dir, config_file, config_file.gsub(/[\w\.]+$/, 'app.config'))
		end
	end

	test_assemblies = Dir['**/bin/Release/*.{Spec}.dll']
	puts "Test assemblies are #{test_assemblies}"
	run_tests(test_assemblies)
end

desc "New task that actually works with reconfiguration to run Specs TeamCity by category"
task :run_smoke_tests, :test_env do |t, args|
	test_type = 'Spec'
	
	root = Dir.pwd
	
	Dir['dependencies/*'].each do |test_dir|
		Dir.chdir test_dir do
			token_replacer = TokenReplacer.new args.test_env, File.join(root, 'global.tokens')
			
			binaries_dir = Dir['**/Release'].first
		
			config_file = Dir["#{binaries_dir}/*.dll.config"].first
			puts "Binaries are in #{binaries_dir}, config is #{config_file}"
			token_replacer.replace_file_matching(binaries_dir, config_file, config_file.gsub(/[\w\.]+$/, 'app.config'))
		end
	end

	test_assemblies = Dir['**/bin/Release/*.{Spec}.dll']
	puts "Test assemblies are #{test_assemblies}"
	run_tests_by_category(test_assemblies, 'smoke')
end



desc "Run Specs TeamCity by category"
task :run_tests_team_city_by_category, :test_env do |t, args|
	
	test_type = 'Spec'
	puts ("environment : #{args.test_env}")
	
	replace_test_config_files_for(args.test_env)	
	run_tests_by_category(AssemblyFinder.new(SOLUTION).get_test_assemblies(test_type), 'smoke')
end

desc "Run acceptance tests"
task :run_acceptance_tests, :test_env do |t, args|
	
	puts ("environment : #{args.test_env}")
	test_type = 'AcceptanceTests'
	replace_test_config_files_for(args.test_env)
	assembly_finder = AssemblyFinder.new(SOLUTION)
	run_tests(assembly_finder.get_test_assemblies(test_type))

	
end

def run_specs(test_assemblies, ignore_categories)

	if ignore_categories.nil?
		ignore = ""
	else
		ignore = "/exclude #{ignore_categories}"
	end


	test_assemblies_arg = test_assemblies.join ' '
	puts "C:\\TeamCityBuildTools\\Nunit\\bin\\net-2.0\\nunit-console.exe #{test_assemblies_arg} /labels /out=TestResult.txt /xml=TestResult.xml  #{ignore} " 
	begin
		sh "C:\\TeamCityBuildTools\\Nunit\\bin\\net-2.0\\nunit-console.exe #{test_assemblies_arg} /labels /out=TestResult.txt /xml=TestResult.xml #{ignore}"
  	rescue
	    puts "Delete failed, ignoring. Probably first time deployment"
	end	
	begin
		puts "C:\\TeamCityBuildTools\\SpecFlow\\specflow.exe nunitexecutionreport dependencies\\#{SOLUTION}.Spec\\#{SOLUTION}.Spec.csproj  /out:Specs.html"
		sh "C:\\TeamCityBuildTools\\SpecFlow\\specflow.exe nunitexecutionreport dependencies\\#{SOLUTION}.Spec\\#{SOLUTION}.Spec.csproj  /out:Specs.html"	
  	rescue
	    puts "Delete failed, ignoring. Probably first time deployment"
	end		
	
end

def run_specs_for_roger(test_assemblies)
	test_assemblies_arg = test_assemblies.join ' '
	puts "C:\\TeamCityBuildTools\\Nunit\\bin\\net-2.0\\nunit-console.exe #{test_assemblies_arg} /labels /out=TestResult.txt /xml=TestResult.xml "
	begin
		sh "C:\\TeamCityBuildTools\\Nunit\\bin\\net-2.0\\nunit-console.exe #{test_assemblies_arg} /labels /out=TestResult.txt /xml=TestResult.xml "
  	rescue
	    puts "Delete failed, ignoring. Probably first time deployment"
	end	
	begin
		puts "C:\\TeamCityBuildTools\\SpecFlow\\specflow.exe nunitexecutionreport dependencies\\Sunshine.Web.Mvc.Functional.Spec\\Sunshine.Web.Mvc.Functional.Spec.csproj  /out:Specs.html"
		sh "C:\\TeamCityBuildTools\\SpecFlow\\specflow.exe nunitexecutionreport dependencies\\Sunshine.Web.Mvc.Functional.Spec\\Sunshine.Web.Mvc.Functional.Spec.csproj  /out:Specs.html"	
  	rescue
	    puts "Delete failed, ignoring. Probably first time deployment"
	end		
	
end


def run_specs_for_smoke(test_assemblies)
	test_assemblies_arg = test_assemblies.join ' '
	puts "C:\\TeamCityBuildTools\\Nunit\\bin\\net-2.0\\nunit-console.exe #{test_assemblies_arg} /labels /out=TestResult.txt /xml=TestResult.xml "
	
	begin
		sh "C:\\TeamCityBuildTools\\Nunit\\bin\\net-2.0\\nunit-console.exe #{test_assemblies_arg} /labels /out=TestResult.txt /include:smoke /xml=TestResult.xml"
		puts "C:\\TeamCityBuildTools\\SpecFlow\\specflow.exe nunitexecutionreport dependencies\\#{SOLUTION}.Spec\\#{SOLUTION}.Spec.csproj  /out:Specs.html"
		sh "C:\\TeamCityBuildTools\\SpecFlow\\specflow.exe nunitexecutionreport dependencies\\#{SOLUTION}.Spec\\#{SOLUTION}.Spec.csproj  /out:Specs.html"	
  	rescue
	    puts "Delete failed, ignoring. Probably first time deployment"
	end	
	
	begin
		puts "C:\\TeamCityBuildTools\\SpecFlow\\specflow.exe nunitexecutionreport dependencies\\#{SOLUTION}.Spec\\#{SOLUTION}.Spec.csproj  /out:Specs.html"
		sh "C:\\TeamCityBuildTools\\SpecFlow\\specflow.exe nunitexecutionreport dependencies\\#{SOLUTION}.Spec\\#{SOLUTION}.Spec.csproj  /out:Specs.html"	
  	rescue
	    puts "Delete failed, ignoring. Probably first time deployment"
	end		
	
end






def run_tests_by_category(test_assemblies, category)
	test_assemblies_arg = test_assemblies.join ' '
	puts "C:\\TeamCity\buildAgent\\plugins\\dotnetPlugin\bin\\JetBrains.BuildServer.NUnitLauncher.exe ANY MSIL NUnit-2.5.5   #{test_assemblies_arg} /category-include:smoke  "
	begin

		sh "C:\\TeamCity\\buildAgent\\plugins\\dotnetPlugin\\bin\\JetBrains.BuildServer.NUnitLauncher.exe ANY MSIL NUnit-2.5.5  #{test_assemblies_arg} /category-include:smoke "
  	rescue
	    puts "Delete failed, ignoring. Probably first time deployment"
	end	
end

def run_tests(test_assemblies)
	test_assemblies_arg = test_assemblies.join ' '
	puts "C:\\TeamCity\\buildAgent\\plugins\\dotnetPlugin\bin\\JetBrains.BuildServer.NUnitLauncher.exe ANY MSIL NUnit-2.5.5   #{test_assemblies_arg}  "
	begin

		sh "C:\\TeamCity\\buildAgent\\plugins\\dotnetPlugin\\bin\\JetBrains.BuildServer.NUnitLauncher.exe ANY MSIL NUnit-2.5.5  #{test_assemblies_arg} "
  	rescue
	    puts "Delete failed, ignoring. Probably first time deployment"
	end	
end

def replace_test_config_files_for(test_environment=nil)
	
end

def require_nunit_launcher
	raise "
		You need to set the <#{TC_NUNIT_ENV_KEY}> environment variable in order to run nunit.
		On Windows you can do that like this: 
			set #{TC_NUNIT_ENV_KEY}=\"path/to/JetBrains.BuildServer.NUnitLauncher.exe
		See: C:/BuildAgent/plugins/dotnetPlugin/bin/JetBrains.BuildServer.NUnitLauncher.exe
	"if NUNIT_LAUNCHER.nil?
end