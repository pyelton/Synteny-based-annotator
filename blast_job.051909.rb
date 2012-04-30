class BlastJob
  def initialize(file_a, file_b)
      @file_a = file_a 
      @file_b = file_b

   
    unless File.exist?("#{file_b.path}.pin")
      `formatdb -i #{file_b.path} -p t -o f`
    end
    outfilename = "./blast_files/#{file_a.path.split("/")[-1]}_vs_#{file_b.path.split("/")[-1]}.blast"
    unless File.exist?("blast_files") == TRUE 
      Dir::mkdir("./blast_files")
    end
    unless File.exists?(outfilename)
      $stderr.puts "about to run blast with #{file_a.path} and #{file_b.path}"
      `blastall -p blastp -i #{file_a.path} -d #{file_b.path} -a 10 -m 8 -v 1 -b 1 -e 1e-10 -o #{outfilename} &`
    end
     outfilename

  end

end
