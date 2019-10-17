#!/usr/bin/env ruby
require './seed_stock.rb'
require './gene_object.rb'
require './cross_object.rb'

# check number of input files and if name are duplicated
if ARGV.uniq.length != 4
  abort "\nError: The number of unique files needed is 4, please check again."
end

puts 'Welcome to Assingment 1!'

# set variables for files
seed_stock_path, cross_data_path, gene_info_path = ''

### CHECKING INPUT FILES ARE CORRECT
puts "\nChecking files..."
# output file must be the last one argument
fname_out = ARGV[-1]
puts fname_out

# arguments not in order, assign paths based on headers
ARGV[0..2].each do |arg|
  puts arg
  if File.file?(arg)
    header = File.open(arg, &:readline)
    seed_stock_header = Regexp.new(/Seed_Stock\tMutant_Gene_ID\tLast_Planted\tStorage\tGrams_Remaining/)
    gene_info_header = Regexp.new(/Gene_ID\tGene_name\tmutant_phenotype/)
    cross_data_header = Regexp.new(/Parent1\tParent2\tF2_Wild\tF2_P1\tF2_P2\tF2_P1P2/)
    seed_stock_path = arg unless seed_stock_header.match(header).nil?
    cross_data_path = arg unless cross_data_header.match(header).nil?
    gene_info_path = arg unless gene_info_header.match(header).nil?
  else
    abort "\nError: Output file must be the last argument, please try again."
  end
end

puts "\nSucces!"

### LOADING DATA
puts "\nCreating new objects..."

Gene.load_from_file(gene_info_path)
puts "Gene object created"
SeedStock.load_from_file(seed_stock_path)
puts "SeedStock object created"
HybridCross.load_from_file(cross_data_path)
puts "HybridCross object created"

### PLANTING SEEDS
puts "\nDo you want to plant in specific stocks?"
ans = $stdin.gets.chomp
if Regexp.new(/[Yy]es|[Ss]i|[Ss]|[Yy]/).match(ans)
  puts "\nPlease enter the stock ids you want to do the planting:"
  list_id = $stdin.gets.chomp.split
  puts "\nPlease enter the number of seeds you want to plant (you can plant different num of seeds for each stock):"
  num_seeds = $stdin.gets.chomp.split
  puts "\nPlanting seeds..."
  inputs = Hash[list_id.zip(num_seeds)]
  inputs.each { |key, value| SeedStock.plant(key, value) }
else
  puts "\nPlease enter the number of seeds you want to plant:"
  num_seeds = $stdin.gets.chomp
  puts "\nPlanting seeds in all stocks..."
  objs = SeedStock.load_from_file(seed_stock_path)
  objs.map { |obj| SeedStock.plant(obj.seed_stock, num_seeds) }
end

### SAVING CHANGES IN DATABASE
SeedStock.write_database(fname_out)
# puts "\nDo you want to update database?"
# ans = $stdin.gets.chomp
# if Regexp.new(/[Yy]es|[Ss]i|[Ss]|[Yy]/).match(ans)
#   SeedStock.write_database(fname_out)
# else
#   puts "\nWarning: an updated file has not been created.\n"
# end

### LINKED GENES REPORT
puts "\nChecking linked genes..."
final_report = []
linked_genes_chi = HybridCross.linked_genes_check
linked_genes_chi.each do |pair|
  *genes, chi = pair
  gene_ids = genes.map { |gene| SeedStock.get_seed_stock(gene).mutant_gene_id }
  gene_names = gene_ids.map { |gene| Gene.get_gene_id(gene).gene_name }
  puts "Recording: #{gene_names[0]} is genetically linked to #{gene_names[1]} with chisquare score #{chi}"
  final_report << " #{gene_names[0]} and #{gene_names[1]} are linked to  each other."
end

puts "\nFinal report:"
puts final_report
puts "\nNew stock file:"
puts IO.readlines(fname_out)
