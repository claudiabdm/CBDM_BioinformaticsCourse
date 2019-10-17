# Represents cross data
class HybridCross
  attr_accessor :parent1
  attr_accessor :parent2
  attr_accessor :f2_wild
  attr_accessor :f2_p1
  attr_accessor :f2_p2
  attr_accessor :f2_p1p2

  def initialize (params = {})
    @parent1 = params.fetch(:parent1, 'XXXX')
    @parent2 = params.fetch(:parent2, 'XXXX')
    @f2_wild = params.fetch(:f2_wild, '0')
    @f2_p1 = params.fetch(:f2_p1, '0')
    @f2_p2 = params.fetch(:f2_p2, '0')
    @f2_p1p2 = params.fetch(:f2_p1p2, '0')
  end

  # creates objects for each record and a list of them so it is easy to access to the objects
  def self.load_from_file(file_path)
    @list_obj = []
    @header = File.open(file_path, &:readline)
    File.readlines(file_path)[1..-1].each do |line|
      data = line.strip.split("\t")
      @list_obj << HybridCross.new(parent1: SeedStock.get_seed_stock(data[0]),
                                   parent2: SeedStock.get_seed_stock(data[1]),
                                   f2_wild: data[2],
                                   f2_p1: data[3],
                                   f2_p2: data[4],
                                   f2_p1p2: data[5])
    end
    @list_obj
  end

  # chi-square
  def chi_sq
    obs = [@f2_wild, @f2_p1, @f2_p2, @f2_p1p2].map(&:to_f)
    total = obs.reduce(:+)
    exp = [9, 3, 3, 1].map { |x| x * total / 16.0 }
    chi = obs.zip(exp).map { |a, b| ((a - b)**2) / b }.reduce(:+)
    chi
  end

  def self.linked_genes_check
    linked_genes_chi = []
    # for 3 degrees of freedom
    value = 7.815
    @list_obj.each do |obj|
      next unless obj.chi_sq >= value

      linked_genes_chi << [obj.parent1.seed_stock.to_s, obj.parent2.seed_stock.to_s, obj.chi_sq]
    end
    linked_genes_chi
  end
end

###### testing the class
# require './seed_stock.rb'
# require './gene_object.rb'
# path1 = './gene_information.tsv'
# Gene.load_from_file(path1)
# path2 = './seed_stock_data.tsv'
# SeedStock.load_from_file(path2)
# path3 = './cross_data.tsv'
# HybridCross.load_from_file(path3)
# puts HybridCross.linked_genes_check
# puts SeedStock.instance_variable_get(:@header)
# puts Gene.instance_variable_get(:@header)
# puts HybridCross.instance_variable_get(:@header)