module Site::Polinostudio::GalleryHelper

  def total_gallery_items_width(gallery)
    #  Values below are based on CSS styles
    separator_width = 100
    margin_width = 4
    
    total = 0
    for item in gallery.gallery_items
      if item.is_a? GalleryPhoto
        total += (item.photo.image_width.to_f / item.photo.image_height * 400).round
      elsif item.is_a? GallerySeparator
        total += separator_width
      end
      total += margin_width
    end

    total
  end

end
