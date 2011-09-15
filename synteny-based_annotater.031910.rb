#!/usr/bin/ruby -w
require 'rubygems'
require 'trollop'
require 'annotation_finder'

# defaults
opts = Trollop::options do
  version "0.1"
  banner <<-EOT
Summary:
  trollop_basic.rb: description

Synopsis:
  synteny-based_annotater.031910.rb --query <synteny_file1> --subject <synteny_file2> --mode <manual or list> --evo_distance <16S etc.> --distance <evo distance value> --list <list_file>
synteny-based_annotater.031910.rb -q <synteny_file1> -s <synteny_file2> -m <manual or list> -e <16S etc.> -d <evo distance value> -l <list_file>

Options:

EOT
  # set options
  opt :evo_distance, "evolutionary distance variable? (default is 16S)", :type => String, :default => "16S"
  opt :mode, "manual or list mode", :type => String, :default => "manual"
  opt :query, "file to enter for the script to run (required filename string)", :type => String
  opt :subject, "file to enter for the script to run", :type => String
#How do I change this so I can put multiple files on :file opt?
  opt :distance, "evo distance value", :type => Float
  opt :list, "list of evolutionary distances", :type => String
end

# options 'bool' is optional if left commented out
# Trollop::die :bool, "is required" unless opts[:bool]
Trollop::die :query, "is required" unless opts[:query] or opts[:list]
Trollop::die :query, "file must exist" unless File.exist?(opts[:query]) or opts[:list]
Trollop::die :evo_distance, "evo_distance must be 16S or Bit_score" unless opts[:evo_distance] =~ /(?:16S|Bit_score)/
Trollop::die :distance, "You must enter an evolutionary distance value" unless opts[:mode] == "list" or opts[:evo_distance]
Trollop::die :list, "File must exist" unless File.exist?(opts[:list]) or opts[:mode] == "manual"
Trollop::die :mode, "Mode must be either manual or list" unless opts[:mode] == "manual" or opts[:mode] == "list"
# custom code starts down here
x = Evo_distance.new(opts)
p_related, evo_dis = x.find_significance.split
z = Annotation_finder.new(p_related, evo_dis, opts)
z.find_synt_genes
