require "spec_helper"
require "translation_support"

describe TranslationSupport do
  describe 'self.get_translation_keys' do
    before do
      @language_root = RADIANT_ROOT + '/spec/fixtures/extensions/locale/config/locales'
    end
    it "should return the word set for the given language root" do
      expect(TranslationSupport.get_translation_keys(@language_root)).to eq({"base:test"=>" 'yes!'"})
    end
    it "should return the word set for the given language root and suffix" do
      suffix = '-uk'
      expect(TranslationSupport.get_translation_keys(@language_root, suffix)).to eq({"base:test"=>" 'UK!'"})
    end
  end
end