# lib/pubmed_parser_helper.rb

class Array
  def print_nicely
    self.each.with_index {|e, i| puts "--- #{i} --- \n#{e}" }
  end
end

class String
  def flatten
    self.gsub(/\n/, ' ')
  end
end
