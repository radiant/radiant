FactoryGirl.define do
  factory :page do
    title 'New Page'
    slug 'page'
    breadcrumb 'New Page'
    status_id '1'
    
    factory :page_with_layout do
      layout
    end
    
    # :parent_id => nil
    
    # factory :admin_user do
    #       spree_roles { [Spree::Role.find_by(name: 'admin') || create(:role, name: 'admin')] }
    #     end
  end
end