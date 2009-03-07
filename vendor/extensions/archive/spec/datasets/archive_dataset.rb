class ArchiveDataset < Dataset::Base
  uses :home_page
  
  def load
    create_page "Archive", :class_name => "ArchivePage" do
      create_page "Year Index", :class_name => "ArchiveYearIndexPage", :title => "%Y Archive"
      create_page "Month Index", :class_name => "ArchiveMonthIndexPage", :title => "%B %Y Archive"
      create_page "Day Index", :class_name => "ArchiveDayIndexPage", :title => "%B %d, %Y Archive"
      (1..5).each do |i|
        create_page "Article #{i}", :published_at => Time.local(1999+i, i, i).to_s(:db)
      end
      create_page "Draft Article", :status_id => Status[:draft].id, :published_at => nil
    end
  end
  
  helpers do
    describe "Archive index page", :shared => true do
      it "should be virtual" do
        @page.should be_virtual
      end
      
      it "should render <r:archive:children:first /> as unimplemented" do
        @page.should render('<r:archive:children:first><r:slug /></r:archive:children:first>').as('unimplemented')
      end

      it "should render <r:archive:children:last /> as unimplemented" do
        @page.should render('<r:archive:children:last><r:slug /></r:archive:children:last>').as('unimplemented')
      end

      it "should <r:archive:children:count /> as unimplemented" do
        @page.should render('<r:archive:children:count><r:slug /></r:archive:children:count>').as('unimplemented')
      end
      
      it "should render the <r:archive:year /> tag" do
        @page.should render("<r:archive:year />").as("2000").on("/archive/2000/")
      end
      
      it "should render the <r:archive:month /> tag" do
        @page.should render("<r:archive:month />").as("June").on("/archive/2000/06/")
      end
      
      it "should render the <r:archive:day /> tag" do
        @page.should render('<r:archive:day />').as("9").on('/archive/2000/06/09/')
      end
      
      it "should render the <r:archive:day_of_week /> tag" do
        @page.should render('<r:archive:day_of_week />').as('Friday').on("/archive/2000/06/09/")
      end
    end
  end
end