class BuildType
	def self.current_build_type
		build_type = :Release
		if ENV.include?('build_type')
			if ENV['build_type'] == 'debug' 
				build_type = :Debug 
			end
		end	
		
		build_type
	end

end
