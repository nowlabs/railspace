class Avatar < ActiveRecord::BaseWithoutTable
  
  # Image directories
  if ENV["RAILS_ENV"] == "test"
    URL_STUB = DIRECTORY = "tmp"
  else
    URL_STUB = "/images/avatars"
    DIRECTORY = File.join("public", "images", "avatars")
  end
  
  # Image sizes
  IMG_SIZE = '"240x300>"'
  THUMB_SIZE = '"50x64>"'
  
  def initialize(user, image = nil)
    @user = user
    @image = image
    Dir.mkdir(DIRECTORY) unless File.directory?(DIRECTORY)
  end
  
  def exists?
    File.exists?(File.join(DIRECTORY, filename))
  end
  
  alias exist? exists?
  
  def url
    "#{URL_STUB}/#{filename}"
  end
  
  def thumbnail_url
    thumb = exists? ? thumbnail_name : "default_thumbnail.png"
    "#{URL_STUB}/#{thumb}"
  end
  
  # Save the avatar images
  def save
    valid_file? and successful_conversion?
  end
  
  # Remove the avatar from the filesystem
  def delete
    [filename, thumbnail_name].each do |name|
      image = "#{DIRECTORY}/#{name}"
      File.delete(image) if File.exists?(image)
    end
  end
  
  # Return true for a valid, nonempty image file
  def valid_file?
    if @image.size.zero?
      errors.add_to_base("Please enter an image filename")
      return false
    end
    unless @image.content_type =~ /^image/
      errors.add(:image, "is not a recognized format")
      return false
    end
    if @image.size > 1.megabyte
      errors.add(:image, "can't be bigger than 1 megabyte")
      return false
    end
    return true
  end
  
  
  # Try to resize image file and convert to the PNG format
  # We use ImageMagick's convert command to ensure sensible image sizes
  # Algorithm:
  # Prepare the filenames for the conversion
  # Ensure that both small and large images work by writing to a normal file
  # Small files show up as String IO, Large files as Tempfiles
  # Convert the file
  # Delete the source file
  def successful_conversion?
    source = File.join("tmp", "#{@user.screen_name}_full_size")
    full_size = File.join(DIRECTORY, filename)
    thumbnail = File.join(DIRECTORY, thumbnail_name)
    File.open(source, "wb") { |f| f.write(@image.read) }
    img = system("#{convert} #{source} -resize #{IMG_SIZE} #{full_size}")
    thumb = system("#{convert} #{source} -resize #{THUMB_SIZE} #{thumbnail}")
    File.delete(source) if File.exists?(source)
    unless img and thumb
      errors.add_to_base("File upload failed: Try a different image")
      return false
    end
    return true
  end
  
  # Returns the filename of the main avatar
  def filename
    "#{@user.screen_name}.png"
  end
  
  # Returns the filename of the avatar's thumbnail
  def thumbnail_name
    "#{@user.screen_name}_thumbnail.png"
  end
  
  # Returns the path to the "convert" program
  # Currently, set statically
  def convert
    "/opt/local/bin/convert"
  end 
  
  private :filename, :thumbnail_name, :convert, :successful_conversion?, :valid_file?
  
  
end