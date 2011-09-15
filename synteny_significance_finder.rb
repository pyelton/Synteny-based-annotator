#finds the significance of evo distance b/w two orgs or a list of pairs for synteny-based annotation purposes


class Evo_distance
  def initialize(opts)
    @evo = opts[:evo_distance]
    if opts[:mode] == "manual"
      @evo_dis = opts[:distance]
    elsif opts[:mode] == "list"
      infile = File.open(opts[:list],"r")
      infile.each do |line|
        if line =~ /#{opts[:subject].split("\/")[-1].split("_vs_")[0]}/ and
           line =~ /#{opts[:subject].split("\/")[-1].split("_vs_")[-1]}/
          if opts[:evo_distance] == "AA_ID"
            @evo_dis = line.split("\t")[3].to_f
          elsif opts[:evo_distance] == "Bit_score"
            @evo_dis = line.split("\t")[5].to_f
          elsif opts[:evo_distance] == "16S"
            @evo_dis = line.split("\t")[-1].to_f
          end
        end
      end
    end

  end #end of initialize

  def find_significance
    #y is the probability that any two syntenous genes are functionally related
    #also known as Pr
    #x is the Pchance derived from the evo_distance
    if @evo == "16S"
    elsif @evo == "Bit_score"
      x = 1.0479*Math.exp(1)**(-33.1642*Math.exp(1)**(-6.5098*@evo_dis))
      y = Math.exp(-3.6925*x) 
    end #end of if @evo
    y = format("%.4f", y)
    puts "The probability that any two syntenous genes are functionally related is: Pr #{y}"
    @sig = y
    "#{@evo_dis} #{@sig}"
  end #end of find_significance

end #end of class Evo_distance
