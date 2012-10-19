task :default => :build

directory 'dist'
directory 'var'

build_deps = [
    'dist/README.md',
    'dist/MIT-LICENSE'
]
desc "Build JavaScript files"
task :build => build_deps do
    puts "build done ..."
end

task :setup => 'var/setup_time' do
    puts "setup done ..."
end

desc "Run automated tests"
task :test => [:build, :setup] do
    puts "run tests ..."
    system 'bin/run_tests.sh'
end

desc "Start over with a clean slate"
task :clean do
    rm_rf 'node_modules'
    rm_rf 'dist'
    rm_rf 'var'
end

file 'var/setup_time' => ['dev_modules', 'var'] do |task|
    list = File.open(task.prerequisites.first, 'r')
    list.each do |line|
        npm_install(line)
    end
    File.open(task.name, 'w') do |fd|
        fd << Time.now().strftime("%Y-%m-%d %H:%M:%S")
    end
end

file 'dist/README.md' => ['README.md', 'dist'] do |task|
    FileUtils.cp task.prerequisites.first, task.name
end

file 'dist/MIT-LICENSE' => ['MIT-LICENSE', 'dist'] do |task|
    FileUtils.cp task.prerequisites.first, task.name
end

def npm_install(package)
    sh "npm install #{package}" do |ok, id|
        ok or fail "npm could not install #{package}"
    end
end
