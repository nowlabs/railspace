module AvatarHelper
  
  # Returns an image tag for the user avatar.
  def avatar_tag(user)
    image_tag(user.avatar.url, :border => 1)
  end
  
  # Returns an image tag for the user avatar thumbnail
  def thumbnail_tag(user)
    image_tag(user.avatar.thumbnail_url, :border => 1)
  end
  
end
