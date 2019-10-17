# Represents the seed stock database
class SeedStock
  attr_accessor :list_obj
  attr_accessor :seed_stock
  attr_accessor :mutant_gene_id
  attr_accessor :last_planted
  attr_accessor :storage
  attr_accessor :grams_remaining

  def initialize(params = {})
    @seed_stock = params.fetch(:seed_stock, 'XXXX')
    @mutant_gene_id = params.fetch(:mutant_gene_id, 'AT0G00000')
    @last_planted = params.fetch(:last_planted, '01/01/1900')
    @storage = params.fetch(:storage, 'xxxx00')
    @grams_remaining = params.fetch(:grams_remaining, '0')
  end

  # creates objects for each record and a list of them so it is easy to access to info
  def self.load_from_file(file_path)
    @list_obj = []
    @header = File.open(file_path, &:readline)
    File.readlines(file_path)[1..-1].each do |line|
      data = line.strip.split("\t")
      @list_obj << SeedStock.new(seed_stock: data[0],
                                 mutant_gene_id: Gene.get_gene_id(data[1]),
                                 last_planted: data[2],
                                 storage: data[3],
                                 grams_remaining: data[4])
    end
    @list_obj
  end

  # transform list of object to hash
  def obj_to_hash
    hash = {}
    instance_variables.each do |var|
      hash[var.to_s.delete('@')] = instance_variable_get(var)
    end
    hash
  end

  # plant a number of seeds from stock in a specific list of ids
  def self.plant(id, num_seeds)
    obj = get_seed_stock(id)
    num_seeds = Integer(num_seeds)
    if num_seeds.positive?
      # substracts num of seeds planted and updtate last planted date
      obj.grams_remaining = obj.grams_remaining.to_i - num_seeds
      obj.last_planted = Time.now.strftime('%d/%m/%Y')
      # if less than or equal to 0 set 0 grams and puts warning with ID
      if obj.grams_remaining <= 0
        obj.grams_remaining = 0
        puts "Warning: we have run out of Seed Stock #{obj.seed_stock}."
      end
    end
  rescue ArgumentError
    puts 'ValueError: input must be an integer number.'
  end

  # method to obtain record info based on id
  def self.get_seed_stock(id)
    id = String(id)
    objs = @list_obj.find { |obj| obj.seed_stock == id }
    abort 'Error: seed stock ∫id not found in database, please try again.' if objs.nil?
    objs
  end

  # method to write in database the num of seeds planted
  def self.write_database(fname_out)
    # open new file to write updated data
    File.open(fname_out, 'w+') do |f|
      # add header
      f.puts(@header)
      @list_obj.each do |obj|
        obj.mutant_gene_id = obj.mutant_gene_id.gene_id.to_s # only writes id.
        f.puts(obj.obj_to_hash.values.join("\t"))
      end
    end
    puts "\nSucces! #{fname_out} added to #{Dir.pwd}\n"
  end
end

###### testing the class
# require './gene_object.rb'
# path1 = 'gene_information.tsv'
# Gene.load_from_file(path1)
# path2 = 'seed_stock_data.tsv'
# SeedStock.load_from_file(path2)
# SeedStock.get_seed_stock('AXXX')
# # plant only for that id and num
# SeedStock.plant('A348', 7)
# SeedStock.write_database('new_data_test.tsv')

# # plants for all database
# objs = SeedStock.load_from_file(path2)
# objs.map { |obj| SeedStock.plant(obj.seed_stock, 7) }
# SeedStock.write_database('new_data_test.tsv')