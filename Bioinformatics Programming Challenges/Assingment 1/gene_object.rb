# Represents genes
class Gene
  attr_accessor :linked_genes
  attr_accessor :header
  attr_accessor :list_obj
  attr_accessor :gene_id
  attr_accessor :gene_name
  attr_accessor :mutant_phenotype

  # check if gene id matches Arabidopsis gene id format.
  def check_id
    gene_id_format = Regexp.new(/A[Tt]\d[Gg]\d\d\d\d\d/)
    return false if gene_id_format.match(@gene_id).nil?
  end

  def initialize(params = {})
    @gene_id = params.fetch(:gene_id, 'AT0G00000')
    if check_id == false
      abort "\nError: Gene ID #{gene_id} doesn't match Arabidopsis format, please try again with this format AT0G00000."
    end
    @gene_name = params.fetch(:gene_name, 'xxx')
    @mutant_phenotype = params.fetch(:mutant_phenotype, 'info not available')
    @linked_genes = params.fetch(:linked, false)
  end

  # creates objects for each record and a list of them so it is easy to access to the objects
  def self.load_from_file(file_path)
    @list_obj = []
    @header = File.open(file_path, &:readline)
    File.readlines(file_path)[1..-1].each do |line|
      data = line.strip.split("\t")
      @list_obj << Gene.new(gene_id: data[0],
                            gene_name: data[1],
                            mutant_phenotype: data[2])
    end
    @list_obj
  end

  # method to get the object with the wanted ID
  def self.get_gene_id(id)
    objs = @list_obj.find { |obj| obj.gene_id == id }
    abort 'Error: gene id not found in database, please try again.' if objs.nil?
    objs
  end
end

###### testing the class
# require 'rest-client'
# path = 'gene_information.tsv'
# Gene.load_from_file(path)

# path2 = 'gene_info_wrong_id.tsv'
# Gene.load_from_file(path2)
