require File.dirname(__FILE__) + '/../spec_helper'

describe Layout do

  let(:layout){ FactoryGirl.build(:layout) }

  describe 'name' do
    it 'is invalid when blank' do
      expect(layout.errors_on(:name)).to be_blank
      layout.name = ''
      expect(layout.errors_on(:name)).to include("this must not be blank")
    end

    it 'should validate uniqueness of' do
      layout.save!
      other = FactoryGirl.build(:layout)
      expect{other.save!}.to raise_error(ActiveRecord::RecordInvalid)
      other.name = 'Something Else'
      expect(other.errors_on(:name)).to be_blank
    end

    it 'should validate length of' do
      layout.name = 'x' * 100
      expect(layout.errors_on(:name)).to be_blank
      layout.name = 'x' * 101
      expect{layout.save!}.to raise_error(ActiveRecord::RecordInvalid)
      expect(layout.errors_on(:name)).to include("this must not be longer than 100 characters")
    end
  end
end
