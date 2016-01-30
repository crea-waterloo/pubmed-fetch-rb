# helper
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

abses_toks = abses.split(/\n\n\n\d+\./)
# ignore 0

abs_1 = abses_toks[1]

abs_toks = abs_1.split(/\n\n/)

abs_pmid = abs_toks[-1].match(/^PMID: (\d+)/)[1]

abs_title = abs_toks[1]

abs_authors = abs_toks[2]

abs_body = abs_toks[4]

abs_body_parts = abs_body.split(/([A-Z]+): /)

abs_body_collected = abs_body_parts.drop(1).each_slice(2).to_a

