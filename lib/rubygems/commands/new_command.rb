require "date"
require "fileutils"

class Gem::Commands::NewCommand < Gem::Command

  def initialize
    super("new", "Creates an empty project", 
          {version_control: "git",
           author: `git config user.name`.chomp,
           dynamic_gemspec: true,
           summary: "", 
           extra_files: [],
           readme: true})
    add_option("--author=NAME", "-a NAME", "Set author's name") do |name|
      options[:author] = name
    end
    add_option("--license=LICENSE", "-l LICENSE", "Specify the license used") do |license|
      options[:license] = license
    end
    add_option("--summary=MESSAGE", "-s MESSAGE", 
               "List MESSAGE as the gemspec's summary") do |summary|
      options[:summary] = summary
    end
    add_option("--add-file=FILENAME", "-f FILENAME", 
               "Add a file to be created in lib/") do |filename|
      options[:extra_files] << filename
    end
    add_option("--min[imum]", "", 
               "Generate only the minimum files without version control") do
      optiosn[:readme] = false
      options[:version_control] = nil
      options[:minimum] = true
    end
    add_option("--static-gemspec", "Generate a static gemspec file") do 
      options[:dynamic_gemspec] = false
    end
    add_option("--no-readme", "Prevent README.md from being generated") do
      options[:readme] = false
    end
    add_option("--version-control EXECUTABLE", "-c EXECUTABLE", 
               "Set version control system used (options: git, mercurial)") do |control|
      options[:version_control] = control unless options[:version_control].nil?
    end
    add_option("--no-version-control", "Prevent setting up version control") do
      options[:version_control] = nil
    end
  end

  def usage
    "#{program_name} NAME"
  end

  def arguments
    "NAME        The name of the gem generated"
  end

  def defaults_str
    <<-DEFAULTS
    --version-control git 
    --author `git config user.name`
    DEFAULTS
  end

  def execute
    @project_name = options[:args][0]
    if @project_name.nil?
      puts "Project name not specified"
      return -1
    end
    if File.directory?(@project_name) && !Dir["#{@project_name}/*"].empty?
      puts "Directory #{@project_name} exists and is non-empty."
      return -1
    end
    write_skeleton
    write_gemspec
    write_readme if options[:readme]
    write_license unless options[:license].nil? 
    add_version_control unless options[:version_control].nil?
  end

  private

  def write_gemspec
    # write required, then optionals
    # dynamic is set by option
    verbose "Creating #{options[:dynamic_gemspec] ? "dynamic" : "static"} gemspec at #{@project_name}/#{@project_name}.gemspec"    
    gemspec_text = if options[:dynamic_gemspec]
<<-GEMSPEC
require "date"
Gem::Specification.new do |s|
  # Required
  s.name = "#{@project_name}"
  s.version = "0.0.1"
  s.summary = "#{options[:summary]}"
  s.author = "#{options[:author]}"
  s.files = Dir["lib/**/*"]
  
  # Recommended
  s.license = "#{options[:license]}"
  s.description = ""
  s.date = Date.today.strftime("%Y-%m-%d")
  s.email = ""
  s.homepage = ""
  s.metadata = {}
  
  
  # Optional and situational - delete or keep, as necessary
  # s.bindir = "bin"
  # s.executables = []
  # s.required_ruby_version = ">= 2.5" # Sensible default
end
GEMSPEC
    else
<<-GEMSPEC
Gem::Specification.new do |s|
  # Required
  s.name = "#{@project_name}"
  s.version = "0.0.1"
  s.summary = "#{options[:summary]}"
  s.author = "#{options[:author]}"
  s.files = [
    "lib/#{@project_name}.rb",
    #{options[extra_files].map{|f| "\"lib/#{f}\""}.join(",    \n")}
  ]
  
  # Recommended
  s.license = "#{options[:license]}"
  s.description = "" #TODO
  s.date = #{Date.today.strftime("%Y-%m-%d")}
  s.email = ""
  s.homepage = ""
  s.metadata = {}
  
  
  # Optional and situational - delete or keep, as necessary
  # s.bindir = "bin"
  # s.executables = []
  # s.required_ruby_version = ">= 2.5" # Sensible default
end
GEMSPEC
    end
    File.open("#{@project_name}/#{@project_name}.gemspec", "w") do |file|
      file.write gemspec_text
    end
  end

  def write_readme
    # write project name and summary
    verbose "Creating #{@project_name}/README.md"
    File.open("#{@project_name}/README.md", "w") do |readme|
      readme.write "# #{@project_name}\n#{options[:summary]}"
    end
  end

  def write_license 
    # does nothing at present. Figure this out later
    # will be specified by option
  end

  def write_skeleton
    # generate lib/<name>.rb and lib/<name> dir
    # Can generate other files if directed by options
    verbose "Creating directory #{@project_name}"
    Dir.mkdir(@project_name)
    Dir.chdir(@project_name) do
      verbose "Creating directory #{@project_name}/lib"
      Dir.mkdir("lib")
      Dir.chdir("lib") do
        verbose "Creating directory #{@project_name}/lib/#{@project_name}"
        Dir.mkdir(@project_name)
        files = [@project_name + ".rb"]
        files += options[:extra_files] unless options[:minimum]
        files.each do |file|
          verbose "Creating file #{@project_name}/lib/#{file}"
          directory = file.split("/")[...-1].join("/")
          FileUtils.mkdir_p(directory) unless directory.empty?
          FileUtils.touch(file)
        end 
      end
    end
  end

  def add_version_control
    # set up git unless other option listed
    verbose "Initializing version control with #{options[:version_control]}"
    case options[:version_control]
    when "git"
      `git init`
    when "mercurial"
      `hg init`
    end
  end

  def verbose(message)
    puts message if Gem.configuration.verbose == 1
  end
end
