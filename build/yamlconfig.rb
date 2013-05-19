require "yaml"

module JazzInc
  module JazzInc::YamlConfig
	def initialize
	  super()
	end

	def configure(yml_file, env = nil)
	  fail("File does not exist: #{yml_file}.") unless File.exists?(yml_file)

	  yaml = YAML::load(File.open(yml_file))

	  configure_from_yaml(yaml, env)
	end

	def configure_from_yaml(yaml, env = nil)
	  fail("Can't work with nil yaml.") if yaml.nil?

	  yaml = env.nil? ? yaml : yaml[env]

	  fail("Unable to locate item <#{env}> in the supplied yaml.") if yaml.nil?

	  parse_config(yaml)
	end

	def parse_config(config)
	  config.each do |key, value|
		setter = "#{key}="
		self.class.send(:attr_accessor, key) unless respond_to?(setter)
		send setter, value
	  end
	end
  end
end

