module ObserveAssets

  def self.included(base)
    base.send :observe, User, Page, Layout, Snippet, Asset
  end

end