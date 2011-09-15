Synteny-based annotation software
----------------------------------------------------------

INSTALLATION

Step 1 - Install Ruby
You can find it here: http://www.ruby-lang.org/en/downloads/
Make sure to include Ruby in your path so that my scripts can find it.



Step 2 - Install Rubygems, Trollop, and Blastall
You can find these here: http://rubygems.org/pages/download
and here: http://ruby.about.com/gi/o.htm?zi=1/XJ&zTi=1&sdn=ruby&cdn=compute&tm=10&f=20&su=p284.12.336.ip_p504.1.336.ip_&tt=2&bt=0&bts=0&zu=http%3A//trollop.rubyforge.org/

You can also install Trollop using rubygems install options.

You can find Blastall here:
http://www.ncbi.nlm.nih.gov/blast/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=Download



Step 3 - Install synteny-based annotator scripts 
These are all contained in the synteny-based annotator .zip file. Put them all in the directory that you plan to run ruby from.

These scripts include the following:
synteny_finder.091311.rb
fasta_parser.rb
blast_pusher.071411.rb
blast_job.051909.rb
blast_parser.071411.rb
synteny_stats.071411.rb
synteny-based_annotater.031910.rb
annotation_finder.rb
synteny_significance_finder.rb



Step 4 - Download the most up-to-date prokaryotic genome.faa files from NCBI
You can ftp these from here: ftp://ftp.ncbi.nih.gov/genomes/Bacteria/
Even though this directory is called "Bacteria" it also contains the archaeal genomes. The file you want is currently called "all.faa.tar.gz," but someday they may change the name.

Put these files in a directory called "ncbi_genomes"



Step 5 - Run the "synteny-finder_071411.rb" ruby script on your genome vs. all of the NCBI genome files

I would suggest making a ruby script to do this. It might look like this:
`ruby synteny_finder.071411.rb -s <output statistics filename> <your genome> <file from ncbi>`

You could also use the Dir.foreach method to run my script for each entry in the ncbi genomes' directory. However beware, there are plasmid sequences included in the subdirectory for each ncbi genome. I usually grab the longest .faa file with the Linux wc command to run my script on. This is at least one of the organism's chromosomes instead of a plasmid.

You should use one name for the output statistics for all of the ncbi genomes vs. your genome



Step 6 - Run the "synteny-based_annotater.031910.rb" script on your genome of interest.

Your command line code should look something like this:

ruby synteny-based_annotater.031910.rb  -q synteny/<query_vs_subject.synteny file> -s synteny/<subject_vs_query.synteny file> -e Bit_score -m list -l synteny_stats_files/<output statistics filename>

Output:
Your output should be a tab-delimited file with old annotations and new predicted annotations for your genome of interest

Known issues: TBA