require 'albacore' 

task :zip_package do
	dirs_to_package = DIRS_TO_PACKAGE
	package_name = "#{SOLUTION}-distribution.zip"

	zd = ZipDirectory.new()
	
	zd.exclusions(/^.*\.(cs|vb|csproj|user|vbproj|resharper|suo|svn)$/)
	zd.directories_to_zip = dirs_to_package
	zd.output_path = "."
	zd.output_file = package_name
	
	zd.instance_eval do
		def zip_directory(zipfile)
			return if @directories_to_zip.nil?
			@directories_to_zip.each do |d|
				Dir["#{d}/**/**"].reject{|f| reject_file(f)}.each do |file_path|
					file_name = file_path
					file_name = file_path.sub(d + '/','') if @flatten_zip

					if !File.directory? file_path
						zipfile.add(file_name, file_path)
					end
				end
			end
		end
	end
	
	p "Zipping directory: #{dirs_to_package} to: #{package_name}"
	zd.execute()
end