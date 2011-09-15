class Blast_pusher

  def initialize(files_hash, genes_hash, opts)
    @files_array = files_hash.to_a 
    @genes_hash = genes_hash
    @blast_files = Array.new
    @opts = opts
  end #end of def initialize

  def self_blast
    @files_array.each do |file_array|
      file_array.each do |filename|
        file_open = File.open(filename,"r")
        filename = filename.split("/")[-1]
        # 1. We run a BLAST if it has not already been run
	  n = BlastJob.new(file_open, file_open)
	  outfilename = "./blast_files/#{filename}_vs_#{filename}.blast"
          @blast_files.push(outfilename)
	  blastfile = File.new(outfilename, "r")	  
        $stderr.puts "adding queries to self_files hash"
      end #end fo arg_array.each do
    end #end of @files_array.each
  end #end of def self_blast

  def self_other_blast
    @files_array.each do |file_array|
      subject = file_array[0]
      query = file_array[1]
      subject_fn = subject.split("/")[-1]
      query_fn = query.split("/")[-1]
      subject_file = File.open(subject, "r")
      query_file = File.open(query,"r")
      n = BlastJob.new(query_file, subject_file)
      outfilename = "./blast_files/#{query_fn}_vs_#{subject_fn}.blast"
      @blast_files.push(outfilename)
      unless @files_array.include?(file_array.reverse)
        @files_array.push(file_array.reverse)
      end #end of unless
    end #end @files_array.each
  end #end of self_other_blast  def parse
  
  def compare
    
    parse = BlastParse.new(@blast_files, @opts, @genes_hash)
    parse.compare
    parse.synt_stats
    @blast_files.clear
  end
end #end of class
