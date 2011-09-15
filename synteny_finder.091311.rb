require 'rubygems'
require 'trollop'
require 'fasta_parser' #allows usage of fasta parser 
require 'blast_pusher.071411'
require 'blast_job.051909'
require 'blast_parser.071411'
require 'ostruct' #allows usage of OpenStruct class

DEBUG = 1
if ARGV.length < 1
	puts "Need at least 1 file. Usage: ruby run_multiple_file_2.rb query1 query2 query3 etc."
	exit(1)
end

# First goes through fasta files and stores length of each ORF
# Then parses m8 BLAST output files for orthologs based on 30% amino acid ID over 70% of the subject
# length for reciprocal best hits
opts = Trollop::options do
  version "0.1"
  banner <<-EOT
Summary:
  trollop_basic.rb: description

Synopsis:
ruby synteny_finder.061710.rb -s <outfile_name> <file1> <file2> ... <filex> <filex+1>

Options:

EOT

  # set options
  opt :stats_outfile, "outfile for synteny statistics", :type => String
end

Trollop::die :stats_outfile, "is required" unless opts[:stats_outfile]

class Multi_files
  attr_accessor :filenames, :work_order, :files_array, :genes_hash, :temp_array
  def initialize(opts)
    gene_hash = Hash.new
    gene_array = Array.new
    @genes_hash = Hash.new
    @arg_array = Array.new
    @files_array = Array.new
    @temp_hash = Hash.new
    @temp_array = Array.new
    $stderr.puts "total file count = #{ARGV.length}" if DEBUG
    @filex =  opts[:stats_outfile] #"STRING_synteny_stats_061710" #STDIN.gets.chomp
    
    #1. I parse the arguments entered onto the command line into an argument array
    ARGV.each do |arg|
        @arg_array.push(arg)
    end #end of ARGV.each do |arg|
    if @arg_array.length > 1 and @arg_array.length  % 2 == 0
      $stderr.puts "we have #{@arg_array.length} files" if DEBUG
      @arg_array.each do |filename|
        unless File.exist?(filename) 
          #1. check to make sure files actually exist
          $stderr.puts "ERROR: #{filename} doesn't exist!"
          exit(1)
        end #end of unless
      end #end of @arg_array.each        
      @arg_array.each do |filename|
        #2. find the lengths of the sequences in the fasta files
        @temp_array.push(filename)
        if @temp_array.length == 2
          @temp_hash = Hash.new
          @temp_hash[@temp_array[0]]=@temp_array[1]
          $stderr.puts "Finding genes for #{@temp_array.join("    ")}"
          @temp_array.each do |file|
            ff = Fasta_file.new(file)    
            gene_hash1 = Hash.new
            objects = ff.each_object
            objects.each do |f|
              unless f.sequence == nil
                @gene = OpenStruct.new
                @gene.index = f.index
                @gene.length = f.sequence.length.to_f
                @gene.name = f.header.split[0]
                function = f.header.split
                function.delete_at(0)
                function.delete_if { |header_element| 
                }  
                function = function.join(" ")
                @gene.function = function
                unless gene_hash1.include?(@gene.name)
                  gene_hash1[@gene.name] = @gene
                end
                @genes_hash[file.split("/")[-1]] = gene_hash1
                @files_array.push @temp_hash.to_a.flatten
              end
            end
          end #end of @temp_array.each
          #3. Initiate the BLASTs and the synteny comparison scripts
          y = Blast_pusher.new(@temp_hash, @genes_hash, opts)
          y.self_blast
          y.self_other_blast
          y.compare
          @temp_array.clear
        end #end of if @temp_array
      end #end fo @arg_array.each do 
    else
      $stderr.puts "You have an odd number of files." +  
        "You need an even number of files."
      exit(1)
    end #end of if @arg_array
  end #end of initialize
end #end of class

o = Multi_files.new(opts)

