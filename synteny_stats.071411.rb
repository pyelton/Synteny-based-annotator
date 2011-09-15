  class Stats
    def initialize(file, file3)
      filea, fileb = file.split("_vs_")
      file1 = "./synteny/" + file
      file2 = "./synteny/" + fileb + "_vs_" + filea
      total_aa = total_length = total_bit = total_block = 0.0
      total_synt = counter = block_counter = 0
      files_to_read = [file1, file2]
      orthologs = ((`wc #{file1}`.split(" ")[0].to_i + `wc #{file2}`.split(" ")[0].to_i)/2).to_i
      files_to_read.each do |f|
        ff = File.open(f, "r")
        ff.each do |line|
          query, q_index, sbjct, s_index, aa_id, length, bit_score, synteny, block_length, orthology, annotation = line.split("\t")
          aa_id = aa_id.to_f
          length = length.to_f
          bit_score = bit_score.to_f
          synteny = synteny.to_i
          block_length = block_length.to_i
          total_aa += aa_id
          total_length += length
          total_bit += bit_score
          total_synt += synteny
          total_block += block_length
          unless block_length == 0
            block_counter += 1
          end #end of unless
          counter += 1
          if @synteny != nil and @synteny > total_synt/2
            total_synt = @synteny
          elsif @synteny != nil
            total_synt = total_synt - @synteny
          end
        end #end of file.each do
      @synteny = total_synt
      end #end of files_to_read.each
      puts "#{filea}\t#{fileb}\tAA ID\t#{(total_aa)/(counter)}\tBit score\t#{(total_bit/counter)}\tSynteny\t#{total_synt}\tBlock length\t#{(total_block/block_counter)}\tOrthologs\t#{orthologs}"
      file3.puts "#{filea}\t#{fileb}\tAA ID\t#{(total_aa)/(counter)}\tBit score\t#{(total_bit/counter)}\tSynteny\t#{total_synt}\tBlock length\t#{(total_block/block_counter)}\tOrthologs\t#{orthologs}"
    end #end of initialize
  end #end of class Stats
