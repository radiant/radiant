require File.dirname(__FILE__) + '/../spec_helper'

describe ArchivePage do
  dataset :archive
  
  before :each do
    @page = pages(:archive)
  end
  
  it "should scope child URLs by date" do
    pages(:article_1).url.should == '/archive/2000/01/01/article-1/'
  end
  
  it "should scope unpublished children by the current date" do
    pages(:draft_article).url.should == '/archive/' + Time.now.strftime('%Y/%m/%d') + '/draft-article/'
  end
  
  it "should find the year index" do
    @page.find_by_url('/archive/2000/').should == pages(:year_index)
  end
  
  it "should find the month index" do
    @page.find_by_url('/archive/2000/06/').should == pages(:month_index)
  end
  
  it "should find the day index" do
    @page.find_by_url('/archive/2000/06/09/').should == pages(:day_index)
  end
  
  it "should find child URLs from the homepage" do
    pages(:home).find_by_url('/archive/2000/01/01/article-1/').should == pages(:article_1)
  end
end