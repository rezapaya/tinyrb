require 'rake/clean'

CC      = "gcc"
CFLAGS  = "-fno-common -g -O2 -pipe -DDEBUG"
LDFLAGS = "-L."

def compile_tasks(exec)
  src = FileList["*.c"]
  obj = src.ext('o')
  
  CLEAN.include('*.o', exec)
  
  desc "Compile #{exec} (default)"
  task :compile => exec
  task :default => :compile
  
  desc "Recompile #{exec}"
  task :recompile => [:clean, :clobber, :compile]
  
  rule ".o" => ".c" do |t|
    sh "#{CC} #{CFLAGS} -c -o #{t.name} #{t.source}"
  end
  
  file exec => obj do |t|
    sh "#{CC} #{LDFLAGS} -o #{exec} #{obj}"
  end
end

def compile_test_tasks(exec, dir, exclude_obj=[])
  src        = "#{exec}.c"
  obj        = src.ext('o')
  
  CLEAN.include(obj, exec)
  
  desc "Compile tests"
  task :compile => [:before_compile, exec]
  
  desc "Run tests (default)"
  task :test => :compile do
    sh "./#{exec}"
  end
  task :default => :test
  
  file obj => src do |t|
    sh "#{CC} #{CFLAGS} -DDEBUG -I#{dir} -c -o #{obj} #{src}"
  end
  
  file exec => obj do |t|
    tested_obj = FileList["#{dir}/*.o"] - exclude_obj
    sh "#{CC} #{LDFLAGS} -o #{exec} #{obj} #{tested_obj}"
  end
end
