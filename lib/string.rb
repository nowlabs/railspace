class String
  
  def or_else(alternate)
    blank? ? alternate : self
  end
  
  def capitalize_each
    space = " "
    split(space).each { |word| word.capitalize! }.join(space)
  end
  
  def capitalize_each!
    replace capitalize_each
  end
  
end