require 'fileutils'
require 'json'

ROOT_DIR = '/dataset'
DRY_RUN = ARGV[0] != '-e' && ARGV[0] != '--execute'

def work_it_bby
  while run_fail? && !DRY_RUN
    puts 'o neee'
  end
end

def run_fail?
  with_trimmed_files do
    system("ruby command.rb") unless DRY_RUN
  end
end

def with_trimmed_files(&block)
  with_dfdc_dirs { |dir| trim_files_of(dir) }
  yield
ensure
  with_dfdc_dirs { |dir| return_files_of(dir) }
end

def return_files_of(dir)
  `cp #{dir}/backup/metadata.json #{dir}/metadata.json`
end

def with_dfdc_dirs(&block)
  Dir["#{ROOT_DIR}/*"]
    .select { |dir| dir.include?('dfdc_train') }
    .each { |dataset_dir| yield(dataset_dir) }
end

def trim_files_of(dir)
  `mkdir -p #{dir}/backup/`
  `cp #{dir}/metadata.json #{dir}/backup/metadata.json`

  done = Dir["#{ROOT_DIR}/boxes/*"].map { |path| File.basename(path, '.*') + '.mp4' }
  crunched = JSON
    .parse(File.read("#{dir}/metadata.json"))
    .reject { |k,v| done.include?(k) }
    .to_json

  if DRY_RUN
    print crunched
  else
    File.write("#{dir}/metadata.json", crunched)
  end
end

work_it_bby
