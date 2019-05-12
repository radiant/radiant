require File.dirname(__FILE__) + "/../spec_helper"

describe TranslationSupport do
  describe 'self.get_translation_keys' do
    before do
      @language_root = RADIANT_ROOT + '/test/fixtures/extensions/locale/config/locales'
    end
    it "should return the word set for the given language root" do
      TranslationSupport.get_translation_keys(@language_root).should == {"base:test"=>" 'yes!'"}
    end
    it "should return the word set for the given language root and suffix" do
      suffix = '-uk'
      TranslationSupport.get_translation_keys(@language_root, suffix).should == {"base:test"=>" 'UK!'"}
    end
  end
end