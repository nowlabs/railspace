class CommunityController < ApplicationController
  def index
    @title = "Community"
    @letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("")
    if params[:id]
      @initial = params[:id]
      @specs = Spec.search_by_initial(@initial, params[:page])
      @users = @specs.collect { |spec| spec.user }
    end
  end

  def browse
    @title = "Browse"
    return if params[:commit].nil?
    if valid_input?
      @specs = Spec.find_by_age_and_sex_and_location(params)
      @users = @specs.collect { |spec| spec.user }
    end
  end
  
  
  # Returns true if the browse form validation input is valid, false otherwise
  def valid_input?
    @spec = Spec.new
    # Spec validation (with @spec.valid?) will catch invalid zip codes
    zip_code = params[:zip_code]
    @spec.zip_code = zip_code
    # There are a good number of zip codes for which there is no information
    location = GeoDatum.find_by_zip_code(zip_code)
    if @spec.valid? and not zip_code.blank? and location.nil?
      @spec.errors.add(:zip_code, "does not exist in our database")
    end
    # The age string should convert to valid integers
    unless params[:min_age].valid_int? and params[:max_age].valid_int?
      @spec.errors.add_to_base("Age range is invalid")
    end
    # The zip code is necessary if miles is provided and vice versa
    miles = params[:miles]
    if (!miles.blank? and zip_code.blank?) || (!zip_code.blank? and miles.blank?)
      @spec.errors.add_to_base("zip code and miles have to be specified together")
    end
    
    # Check for invalid location radius if present
    @spec.errors.add_to_base("Location radius is invalid") if !miles.blank? && !miles.valid_float?
    
    
    # The input is valid iff the errors object is empty
    @spec.errors.empty?
  end
  
  private :valid_input?

  def search
    @title = "Search RailsSpace"
    if params[:q]
      query = params[:q]
      begin
        #First find the user hits
        users = User.find_by_contents(query, :limit => :all)
        #Then find the subhits in the Faq and Spec models
        specs = Spec.find_by_contents(query, :limit => :all)
        faqs = Faq.find_by_contents(query, :limit => :all)
        #Combine the subhits to retrieve the user collection from the subhits
        hits = specs + faqs
        #Extract the users from the subhits, concatenate with original user list and remove duplicates
        users.concat(hits.collect{ |hit| hit.user }).uniq!
        # Sorting by last name which requires a spec for each user 
        users.each { |user| user.spec ||= Spec.new }
        users = users.sort_by { |user| user.spec.last_name }
        #Paginate the search results
        specs = users.collect { |user| user.spec }
        @specs = specs.paginate(:per_page => 10, :page => params[:page])
        @users = @specs.collect { |spec| spec.user }
      rescue Ferret::QueryParser::QueryParseException
        @invalid = true
      end
    end
  end

end
