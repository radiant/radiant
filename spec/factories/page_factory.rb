FactoryGirl.define do
  factory :page do
    title 'New Page'
    slug 'page'
    breadcrumb 'New Page'
    status_id '1'
    
    factory :page_with_layout do
      layout
    end
  end
end