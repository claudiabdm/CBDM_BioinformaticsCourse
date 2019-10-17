require 'rest-client'
require './gene_object2.rb'

path = 'gene_information.tsv'
objs = Gene.load_from_file(path)
embl_list = []

#     (easy) read the gene_information.tsv file from your assignment; retrieve the EMBL record for each gene in that file (please retrieve them one-at-a-time, not all together)
def retrieve_embl(id)
  address = "http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{id}"
  response = RestClient::Request.execute(method: :get, url: address)
  response.body
end

objs.each do |obj|
  gene_id = obj.gene_id
  embl_list << retrieve_embl(gene_id)
  embl_list.match('/SQ/')
end

puts embl_list[1]
# (medium) Create an AnnotatedGene Class, that extends the Gene Class by adding the DNA sequence and the Protein sequence attributes (as Strings).

class AnnotatedGene  < Gene
    def retrieve_dna_seq
      objs.each do |obj|
        gene_id = obj.gene_id
        embl_list << retrieve_embl(gene_id)

      end
    end
end

# (hard) For every EMBL file retrieved from gene_information.tsv, find the cross-referenced UniProt identifier (needs a regular expression).

