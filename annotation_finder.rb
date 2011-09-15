 #Looks for synteny between two organisms and uses it to improve/determine annotations
#first it needs to determine evo distance between the organisms
#Then it looks for synteny
#Then it examines annotations
#then it improves them

require 'synteny_significance_finder'
require 'ostruct'

class Annotation_finder
  def initialize(evo_dis, sig, opts)
    @evo_dis = evo_dis
    @sig = sig
    @file1 =  opts[:query]
    @file2 = opts[:subject]
    unless File.exist?(@file1) and File.exist?(@file2)
      $stderr.puts "ERROR: file #{@file1} or file {@file2} doesn't exist!"
      exit(1)
    end #end of unless File.exist
  end

  def find_synt_genes
    #in order to look only for first genome you could treat each file differently in the annotate method
    significant_bscore = 0.3348
    org_hash = Hash.new #organism hash
    @gene_hash = Hash.new
    $stderr.puts @file1
    file = File.open(@file1, "r")
    @synteny_array = Array.new
    a = []
    @synteny_hash= {}
    block_end = FALSE
    file.each do |line|
      if line.split("\t")[-5].to_f == 1 #if the gene is syntenous
        @synteny_array.push(line)
        gene1, q_index, gene2, s_index, aa_id, length, b_score, synt, block, ortholog, annotation, new_annotation = line.split("\t") ##changed this today (added new annotation because this is in fact on the line) Now things arent working
        synteny = OpenStruct.new
        synteny.gene1 = gene1
        #synteny.org1, synteny.org2 = file.split("_vs_")
        synteny.q_index = q_index.to_i
        synteny.s_index = s_index.to_i
        synteny.gene2 = gene2
        synteny.aa = aa_id
        synteny.bit = b_score
        synteny.block = block
        synteny.ortholog = ortholog   
        synteny.new_fxn = new_annotation
        if annotation =~ /;/
          synteny.fxn = annotation.split(";")[0..-3].join(";")
        else
          synteny.fxn = annotation
        end
        if annotation.split(";")[-1].length == 2
          synteny.rank = annotation.split(";")[-1]
        elsif annotation =~ /;\t [A-H]\t/ or annotation =~ /(GENE)/
          synteny.rank = annotation.split(";")[-1]
        else
          synteny.rank = "NA"
        end
        if synteny.block.length == 0 and block_end == FALSE #Creates arrays of syntenous genes in a hash with a key for each gene
          a.push(synteny.gene1)
        elsif synteny.block.length == 1
          block_end = TRUE
          @synteny_hash[synteny.gene1] = a
          a.each do |gene| 
            b = a.reject {|v| v == gene}
            @synteny_hash[gene] = b.push(synteny.gene1)
          end
          a = []
        elsif block_end == TRUE
          block_end = FALSE
          a.push(synteny.gene1)
        end
        synteny.probability = 0
        @gene_hash[synteny.gene1] = synteny #creates a hash that holds all the gene information for syntenous genes
      end #end of if line.split
    end #end of file.each
    org_hash[file] = @synteny_array
    last_gene = nil
#    @gene_hash.sort.each do |key, gene|
#      if @gene_hash.key?(gene.gene2) and gene.org1 == @file1.split("_vs_")[0]
#        #if gene_hash contains both gene1 and gene2 as syntenous genes
#        gene2_fxn = @gene_hash[gene.gene2].fxn
#        if gene.fxn =~ /(?:hypothetical|unknown|unassigned|unclassified|undetermined|uncharacteri[sz]ed|putative|probable|predicted)/i 
#          gene.new_fxn = gene2_fxn
#          gene.probability = @sig
#        elsif gene.rank =~/D|E/i and gene.rank !~ /NA/
#          gene.new_fxn = gene2_fxn
#          gene.probability = @sig
#        end
#      end #end of @gene_hash.each do
#    end
    general_outfile = File.new("/home/pepper/synteny-based_annotation_files/#{@file1.split("/")[-1].split(".")[0]}.general_synteny-annotation", "a")
    general_outfile.puts "Improved gene\tSyntenous ortholog\tEvolutionary Distance\tAnnotation\tRank\tOrtholog annotation\tSyntenous Genes and Annotations"
    gene_array = Array.new
    @gene_hash.sort.each do |key, value|

      #general annotation file
      if @evo_dis.to_f < significant_bscore # temporary to keep the file small
        gene_array = [key, value.gene2, @evo_dis, value.fxn.chomp, value.rank, value.new_fxn.chomp]
        unless  @synteny_hash[key] == nil
          @synteny_hash[key].each { |gene| gene_array.push(gene) }
          general_outfile.puts gene_array.flatten.join("\t")
        end
      end
    end
  end #end of def find_synt_genes
end #end of class Annotater


