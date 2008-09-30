
module FunctionHelper
  
  require 'string'
  require 'will_paginate_ext'
  require 'object'
    
  def raise_option_missing_error(error, options, *keys)
    keys.flatten.each do |key|
      raise error, 
            "attributes must have the \"#{key}\" key,value set" unless options.has_key?(key.to_sym)
    end
  end
  
end