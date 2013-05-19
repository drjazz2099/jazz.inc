require File.expand_path("#{File.dirname(__FILE__)}/build_type.rb")

class AssemblyFinder 

	attr_accessor :build_type, :all_assemblies, :solution
		
	def initialize(solution)
		@build_type = BuildType.current_build_type
		puts "build type = #{@build_type}"
		
		@solution = solution
		puts "solution = #{@solution}"

		assemblies = Dir["**/#{solution}*"].find_all {|item| item =~ /\/#{solution}.*.(?:dll|exe)$/ }
		assemblies = assemblies.delete_if {|item| item =~ /(?:XmlSerializers.dll$)/}
		assemblies = assemblies.delete_if {|item| item =~ /\/obj/}
		
		puts "all solution assemblies:"
		puts assemblies
		
		@all_assemblies = assemblies
	end
	
	def get_test_assemblies(test_type)
		result = all_assemblies.find_all {|item| item =~ /(:?.#{test_type}).dll$/}
		puts "#{test_type} test assemblies for solution #{@solution} =>"
		puts result.empty? ? "==NONE FOUND==" : result
		raise "No test assemblies found!" if result.empty?
		result
	end
	
	def get_solution_code_assemblies(root_project_name)
		puts "root project name = #{root_project_name}"

		solution_code_assemblies = get_assemblies(root_project_name).find_all{|item| item =~ /#{root_project_name}\/.*\/#{@solution}.*/}
		puts "solution code assemblies => "
		puts solution_code_assemblies.empty? == true ? "==NONE FOUND==" : solution_code_assemblies
		
		solution_code_assemblies
	end
	
	def get_dependency_assemblies(root_project_name)
			
		dependency_code_assemblies = get_assemblies(root_project_name) - get_solution_code_assemblies(root_project_name)
		puts "dependency code assemblies => "
		puts dependency_code_assemblies.empty? == true ? "==NONE FOUND==" : dependency_code_assemblies
		
		dependency_code_assemblies
	end
	
	def get_assemblies(root_project_name)
		code_assemblies = all_assemblies.find_all{|item| item =~ /#{root_project_name}\/.*/}
		puts "all code assemblies => "
		puts code_assemblies.empty? == true ? "==NONE FOUND==" : code_assemblies
		code_assemblies
	end

end