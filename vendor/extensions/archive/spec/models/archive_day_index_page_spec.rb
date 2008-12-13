require File.dirname(__FILE__) + '/../spec_helper'

describe ArchiveDayIndexPage do
  dataset :archive
  
  before :each do
    @page = pages(:day_index)
  end
  
  it_should_behave_like "Archive index page"
  
  it "should render the <r:archive:children:each /> tag" do
    @page.should render('<r:archive:children:each><r:slug /> </r:archive:children:each>').as('article-2 ').on('/archive/2001/02/02/')
    @page.should render('<r:archive:children:each><r:slug /> </r:archive:children:each>').as('article-2 ').on('/archive/2001/02/02')
  end
  
  it "should render the <r:title /> tag with interpolated date" do
    @page.should render('<r:title />').as('June 09, 2000 Archive').on('/archive/2000/06/09/')
  end
end