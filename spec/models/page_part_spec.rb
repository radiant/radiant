require 'spec_helper'

class PseudoTextileFilter < TextFilter
  def filter(text)
    text + ' - Filtered with TEXTILE!'
  end
end

class PseudoMarkdownFilter < TextFilter
  def filter(text)
    text + ' - Filtered with MARKDOWN!'
  end
end

describe PagePart do

  before do
    @original_filter = Radiant.detail['defaults.page.filter']
    @part = @model = FactoryGirl.build(:page_part)
  end

  after do
    Radiant.detail['defaults.page.filter'] = @original_filter
  end

  it "should take the filter from the default filter" do
    Radiant.detail['defaults.page.filter'] = "Pseudo Textile"
    part = PagePart.new name: 'new-part'
    expect(part.filter_id).to eq("Pseudo Textile")
  end

  it "shouldn't override existing page_parts filters with the default filter" do
    @part.save!
    selected_filter_name = TextFilter.descendants.first.filter_name
    Radiant.detail['defaults.page.filter'] = selected_filter_name
    @part.reload
    expect(@part.filter_id).not_to eq(selected_filter_name)
  end

  it 'should validate length of' do
    {
      name: 100,
      filter_id: 25
    }.each do |field, max|
      @part.send("#{field}=", 'x' * max)
      expect(@part.errors_on(field)).to be_blank
      @part.send("#{field}=", 'x' * (max + 1))
      expect(@part.errors_on(field)).to include("this must not be longer than #{max} characters")
    end
  end

  it 'should validate presence of' do
    @part.name = ''
    expect(@part.errors_on(:name)).to include("this must not be blank")
  end
end

describe PagePart, 'filter' do
  specify 'getting and setting' do
    # page = FactoryGirl.build(:page)
    @part = FactoryGirl.build(:page_part, name: 'body', filter_id: 'Pseudo Textile')
    original = @part.filter
    expect(original).to be_kind_of(PseudoTextileFilter)

    expect(@part.filter).to equal(original)

    @part.filter_id = 'Pseudo Markdown'
    expect(@part.filter).to be_kind_of(PseudoMarkdownFilter)
  end
end
