module UrlAdditions
  
  Paperclip::Attachment.interpolations[:no_original_style] = lambda do |attachment, style|
    style ||= :original
    style == attachment.default_style ? nil : "_#{style}"
  end
  
end
  

