FactoryGirl.define do
  factory :page do
    title       'Page'
    breadcrumb  { title }
    slug        { title.slugify }

    factory :page_with_layout do
      layout
    end

    factory :page_with_page_parts do
      page_parts
    end

    factory :file_not_found_page, :class => FileNotFoundPage do
    end
    
    factory :published_page do
      status_id Status[:published].id

      factory :article do
        title { generate(:article_title)}
        slug { generate(:article_slug)}
      end

      # factory :child do
      #   sequence(:title, 1) { |n| "Child#{(' ' + n.to_s) unless n == 1 }" }
      #   sequence(:slug, 1) { |n| "child#{('-' + n.to_s) unless n == 1 }" }
      #   page_parts
      # end
      
      factory :page_with_body_page_part do
        after(:create) { |page| page.parts.create(:name => 'body', :content => "#{page.title} body.") }
      end
      
      factory :page_with_body_and_sidebar_parts do
        after(:create) { |page| page.parts.create(:name => 'body', :content => "#{page.title} body.") }
        after(:create) { |page| page.parts.create(:name => 'sidebar', :content => "#{page.title} sidebar.") }
      end
    end
    
    factory :home do |home|
      title 'Home'
      slug '/'
      status_id Status[:published].id
      parent_id nil
    end
    
  end
  
  sequence :article_slug do |n|
    "article#{('-' + n.to_s) unless n == 1 }"
  end
  sequence :article_title do |n|
    "Article#{(' ' + n.to_s) unless n == 1 }"
  end
end
