require 'ostruct'

class Fasta_file
  attr_reader :file, :sequence, :header
  def initialize(fasta_file)
    @sequence = Array.new
    @file = File.open(fasta_file)
  end
  def each_object #goes through file fasta objects
    fasta = OpenStruct.new
    sequence = Array.new
    index = 0
    buffer = Array.new
    @file.each_line do |line|
      if line =~ />/
        unless index == 0
          buffer.push(fasta)
        end
        fasta = OpenStruct.new
        fasta.header = line.split(">")[1]
        fasta.index = index
        fasta.index = index += 1
        sequence = Array.new
      else
        sequence.push(line.chomp)
        fasta.sequence = sequence.to_s
      end
    end
    buffer.push(fasta)
    @buffer = buffer
  end
end #end of Fasta class




