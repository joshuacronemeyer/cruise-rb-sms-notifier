task :default => [:test]
task :cruise => [:test]
task :test do |t|
	test_files = FileList['*test*']
	test_files.each do |file| 
		if !system("ruby #{file}")
			exit 1
		end
	end
end
