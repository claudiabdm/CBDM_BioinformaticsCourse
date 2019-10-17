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
  end

  # transform list of object to hash
  def obj_to_hash
    hash = {}
    instance_variables.each do |var|
      hash[var.to_s.delete('@')] = instance_variable_get(var)
    end
    hash
  end

  # method to plant a number of seeds from stock
  def plant(num_seeds)
    if num_seeds.is_a? Integer
      # substracts num of seeds planted and updtate last planted date
      @grams_remaining = @grams_remaining.to_i - num_seeds
      @last_planted = Time.now.strftime('%d/%m/%Y')
      # if less than or equal to 0 set 0 grams and puts warning with ID
      if @grams_remaining <= 0
        @Integergrams_remaining = 0
        return "Warning: we have run out of Seed Stock #{@seed_stock}"
      end
    else
      abort "\nPlease enter an integer number."
    end
  end

  # method to obtain record info based on id
  def self.get_seed_stock(id)
    objs = @list_obj.select { |obj| obj.seed_stock == id }
    objs[0]
  end

  # method to write in database the num of seeds planted
  def self.write_database(fname_out, num_seeds)
    # open new file to write updated data
    File.open(fname_out, 'w+') do |f|
      # add header
      f.puts(@header)
      @list_obj.each do |obj|
        puts obj.obj_to_hash.values.join("\t")
        obj.plant(num_seeds)
        f.puts(obj.obj_to_hash.values.join("\t"))
      end
    end
    "Succes! #{fname_out} added to #{Dir.pwd}"
  end
end

###### testing the class
require './gene_object2.rb'
path1 = 'gene_information.tsv'
Gene.load_from_file(path1)
path2 = 'seed_stock_data.tsv'
puts SeedStock.load_from_file(path2)
puts SeedStock.get_seed_stock('A348').seed_stock
puts SeedStock.write_database('new_data_test.tsv', 7 )
