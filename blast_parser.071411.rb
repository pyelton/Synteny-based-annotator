require 'synteny_stats.071411'

class BlastParse #Defines class and methods for blast files (attribute accessors allow you to use x.q_start to access @q_start for example)
  attr_accessor :query, :sbjct, :percent, :a_length
  attr_accessor :mismatch_count, :gap_count
  attr_accessor :q_start, :q_end, :s_start, :s_end
  attr_accessor :e_value, :bit_score
  attr_accessor :hit_hash

  def initialize(blastfilenames, opts, genes_hash) 
  #Defines initialize method that splits each blast line into temporary variables
    @genes_hash = genes_hash 
    @genes_hash.each do |k, v|
    end
    #This is a hash with organism names as the key and a hash as the value
    #The hash within the @genes_hash value (gene_hash) has a gene_name as the key and an OpenStruct object for the gene as the value
    @hit_hash = Hash.new
    @max_score_hash = Hash.new
    @opts = opts
    @ortholog_hash = Hash.new
    @stats_array = Array.new
    blastfilenames.each do |outfilename| #We make sure that we don't already have the synteny files for this pairwise comparison
      file1 = file_split(outfilename)[0]
      file2 = file_split(outfilename)[1]
      blastfile1 = "./blast_files/" + file1 + "_vs_" + file1 + ".blast"
      blastfile2 = "./blast_files/" + file2 + "_vs_" + file2 + ".blast"
      if file1 != file2 and File.exist?("./synteny/" + synt_file(outfilename, ".blast")[0]) == TRUE and File.exist?("./synteny/" + file_recip(outfilename)) == TRUE
        blastfilenames.delete(outfilename)
        blastfilenames.delete("./blast_files/" + file_recip(outfilename) + ".blast")
        blastfilenames.delete(blastfile1)
        blastfilenames.delete(blastfile2)
        @stats_array.push(synt_file(outfilename, ".blast")[0])
      elsif file1 != file2 #We get ready to parse the blast files
        unless @stats_array.include?(file_recip(outfilename))
          @stats_array.push(synt_file(outfilename, ".blast")[0])
        end
      end #end of if File.exist?
    end #end of blastfilenames.each
    blastfilenames.each do |outfilename|
      @file_a = synt_file(outfilename, "_vs_")[0]      
      @file_b = synt_file(outfilename, "_vs_")[-1].split(".blast")[0]
    blast_file = File.open(outfilename, 'r')
      hit_hash1 = Hash.new
      blast_file.each do |line|
        @hit = OpenStruct.new
        @hit.query, @hit.sbjct, @hit.aa_id, 
        @hit.a_length, @hit.mismatch_count, 
        @hit.gap_count, @hit.q_start, @hit.q_end, 
        @hit.s_start, @hit.s_end, @hit.e_value, 
        @hit.bit_score = line.split  
        @hit.aa_id = @hit.aa_id.to_f
        @hit.a_length = @hit.a_length.to_f        
        @hit.bit_score = @hit.bit_score.to_f
        @hit.name = @hit.query + " " + @hit.sbjct
        if file_split(outfilename)[0] == file_split(outfilename)[1]
          #Adds the max scores for each query to a hash if the blast is a self blast
          @max_score_hash[@hit.query] = @hit.bit_score
        else
          #This finds length ratios and calculates normalized bit scores
          @hit.length_ratio = @hit.a_length/@genes_hash[@file_a][@hit.query].length
          @hit.norm_score = @hit.bit_score/((@max_score_hash[@hit.query].to_f + @max_score_hash[@hit.sbjct].to_f)/2)
          @hit.q_index = @genes_hash[@file_a][@hit.query].index
          @hit.q_fxn = @genes_hash[@file_a][@hit.query].function
          @hit.s_index = @genes_hash[@file_b][@hit.sbjct].index
          @hit.s_fxn = @genes_hash[@file_b][@hit.sbjct].function
        end
        hit_hash1[@hit.name] = @hit
      end #end of blast_file.each
      $stderr.puts "Done with parsing blast file #{outfilename}"
      blast_file.close
      unless @hit_hash.key?(outfilename) or @file_a == @file_b
        @hit_hash[outfilename] = hit_hash1
      end
    end #end of blastfilenames.each
  end #end of initialize

  def file_split(file)
    synt_file(file, ".blast")[0].split("_vs_")
  end
  
  def file_recip(file)
    file_split(file)[1] + "_vs_" + file_split(file)[0]
  end
  
  def synt_file(file, delimiter)
    file.split("/")[-1].split(delimiter)
  end

  def compare  
    $stderr.puts "Looking for reciprocal best hits"
    @hit_hash.each do |file, hits| #Looks for orthologs
      file_a = synt_file(file, "_vs_")[0]
      file_b = synt_file(file, "_vs_")[-1].split(".blast")[0]
      if file_a != file_b
        hits.each do |hit_name, hit|
        @hit_hash.each do |new_file, new_hits|
            newfile_a = synt_file(new_file, "_vs_")[0]
            newfile_b = synt_file(new_file, "_vs_")[-1].split(".blast")[0]
            if newfile_a == file_b and newfile_b == file_a
              hit_a, hit_b = hit_name.split(" ")
              new_hit_name = hit_b + " " + hit_a
              if new_hits.include?(new_hit_name)
                new_hit = new_hits[new_hit_name]
                  if hit.length_ratio >= 0.70 and new_hit.length_ratio >= 0.70 and hit.aa_id >= 0.30
                    new_hit.orth = hit.orth = "ortholog"
                  elsif hit.length_ratio >= 0.50 and new_hit.length_ratio >= 0.50 and hit.aa_id >= 0.20
                    new_hit.orth = hit.orth = "possible ortholog"
                  else
                    hit.orth = 0
                  end
              end #end of if new_hits.include
            end #end of if newfile_a ==
          end #end of hit_hash.each (new_hits)
        end #end of hits.each
      end #end of if file_a != file_b
      @hit_hash.each do |file, hits| #assigns orthologs to files and files to file hash
        ortholog_hash = Hash.new
        hits.each do |hit_name, hit|
          if hit.orth == "ortholog" or hit.orth == "possible ortholog"
            ortholog_hash[hit_name] = hit
          end
         end
        unless synt_file(file, "_vs_")[0] == synt_file(file, "_vs_")[-1].split(".blast")[0] 
          @ortholog_hash[file] = ortholog_hash
        end
      end
    end #end of hit_hash.each (hits)
    final_synteny
  end # end of compare

  def final_synteny
    unless @hit_hash.empty? == TRUE
      $stderr.puts "Searching for synteny"
      @ortholog_hash.each do |file, hits_hash|
        file_a = synt_file(file, "_vs_")[0]
        file_b = synt_file(file, "_vs_")[-1].split(".blast")[0]
          @hit_hash[file] = hits_hash = hits_hash.sort { |a,b| a[1].q_index <=> b[1].q_index}
          previous_q = previous_s = acounter = 0
          previous = hits_hash[0][1]
          counter = 1
          hits_hash.each do |hit_name, hit|
            if hit.orth == "ortholog"
              acounter += 1
            end
            if hit.orth = "ortholog" and previous.orth == "ortholog"
              if hit_name =~ /PL_/ and hit.query =~ /PL_/ 
                contig = hit.query.split("PL_")[1].split("_")[0]
                previous_contig = previous.query.split("PL_")[1].split("_")[0]
              elsif (hit_name != /PL_/ and hit.query != /PL_/)
                contig = previous_contig = 0
                #This makes sure hits are on the same contig for the plasma. It does not work if both organisms being compared are plasmas
                #In that case you must use the blast_parser.3genes.052810.rb
              end
                if contig = previous_contig
                  if  (hit.q_index.between?(previous_q, previous_q +3)  and hit.s_index.between?(previous_s, previous_s + 3))  or
                      (hit.q_index.between?(previous_q - 3, previous_q) and hit.s_index.between?(previous_s - 3, previous_s))  or
                      (hit.q_index.between?(previous_q, previous_q + 3) and hit.s_index.between?(previous_s - 3, previous_s))  or
                      (hit.q_index.between?(previous_q - 3, previous_q) and hit.s_index.between?(previous_s, previous_s + 3))
                    hit.synteny = previous.synteny = 1
                    counter += 1
                  else
                    hit.synteny = 0
                    if counter != 1
                      previous.block = counter
                    end
                    counter = 1
                  end #end of if (hit.
                end
                #previous.query = hit.query
                previous_q = hit.q_index
                previous_s = hit.s_index
                previous = hit
            end #end of if hit.orth
            previous.query = hit.query
          end #end of hits_hash.each
        end #end of if file_a
      end #end @hit_hash.each do
      counter = 0
      @hit_hash.each do |file, hits_hash|
        file_a = synt_file(file, "_vs_")[0]
        file_b =  synt_file(file, "_vs_")[-1].split(".blast")[0]
          unless File.exist?("synteny") == TRUE
            Dir::mkdir("./synteny/")
          end
          filename = synt_file(file, ".blast")[0]
          file1 = File.new("./synteny/" + filename, 'w+')
          hits_hash.each do |hit_name, hit|
            unless hit == nil or hit.orth == 0
#              puts "#{hit.query}\t#{hit.q_index}\t#{hit.sbjct}\t#{hit.s_index}\t#{hit.aa_id}\t#{hit.length_ratio}\t#{hit.norm_score}\t#{hit.synteny}\t#{hit.block}\t#{hit.orth}\t" ##{hit.q_fxn}\t#{hit.s_fxn}"
              file1.puts "#{hit.query}\t#{hit.q_index}\t#{hit.sbjct}\t#{hit.s_index}\t#{hit.aa_id}\t#{hit.length_ratio}\t#{hit.norm_score}\t#{hit.synteny}\t#{hit.block}\t#{hit.orth}\t#{hit.q_fxn}\t#{hit.s_fxn}"
            end #end of unless hit
          end # end of hits_hash.each
          @hit_hash.delete(file)
          file1.close
          $stderr.puts "----------- done with #{file} ----------------\n\n"
    end #end of @hit_hash.each
  end # end of final_synteny

  def synt_stats
    unless File.exist?("synteny_stats_files") == TRUE
      Dir::mkdir("./synteny_stats_files/")
    end
    file2 = File.new("./synteny_stats_files/" + @opts[:stats_outfile], "a") 
    @stats_array.each do |synt_file|
      file_to_stats = Stats.new(synt_file, file2)
    end
  end
end # end of class 
