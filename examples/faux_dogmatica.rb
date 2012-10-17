# Some fake examples.  Here's how I'd like to be able to write code
# with this framework.
require './lib/stepladder'

stepladder do

  starter do
    statement = "The quick brown fox jumped over the lazy dog."
    statement.split(/\s/).each do |word|
      handoff word
    end
  end

  worker "Animal ScareQuoter" do |word|
    if ["fox", "dog"].include?(word)
      word = "\"#{word}\""
    end
    word
  end

  filter "out colors!" do |word|
    ! ["brown", "blue", "beige"].include?(word)
  end

  worker "Incredulizer!?" do |word|
    if @last_word
      nil
    elsif word.nil?
      @last_word = true
      "??!"
    else
      word
    end
  end

end
