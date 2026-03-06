# Replacement for stringex gem's to_slug method
class String
  def to_slug
    gsub(/[^\w\s-]/, '').gsub(/\s+/, '-').downcase
  end
end
