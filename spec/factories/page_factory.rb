FactoryGirl.define do
  factory :page do
    title       'Page'
    breadcrumb  { title }
    slug        { title.slugify }
    
    status_id '1'

    factory :page_with_layout do
      layout
    end
    
    factory :page_with_page_parts do
      page_parts
    end

    factory :file_not_found_page, :class => FileNotFoundPage do
    end
    
    factory :published_page do
      status_id '100'
    end
    
    factory :home do |home|
      title 'Home'
      slug '/'
      status_id '100'
      parent_id nil
    end
  end
end
