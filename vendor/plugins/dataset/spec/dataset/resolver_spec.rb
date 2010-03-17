require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

ResolveThis = Class.new(Dataset::Base)
ResolveDataset = Class.new(Dataset::Base)
SomeModelNotDs = Class.new
SomeModelNotDsDataset = Class.new(Dataset::Base)
NotADataset = Class.new
TheModule = Module.new
TheModuleDataset = Class.new(Dataset::Base)

describe Dataset::Resolver do
  before do
    @resolver = Dataset::Resolver.new
  end
  
  it 'should skip modules' do
    @resolver.resolve(:the_module).should == TheModuleDataset
  end
  
  it 'should find simply classified' do
    @resolver.resolve(:resolve_this).should == ResolveThis
  end
  
  it 'should find ending with Dataset' do
    @resolver.resolve(:resolve).should == ResolveDataset
  end
  
  it 'should keep looking if first try is not a dataset' do
    dataset = @resolver.resolve(:some_model_not_ds)
    dataset.should_not be(SomeModelNotDs)
    dataset.should == SomeModelNotDsDataset
  end
  
  it 'should indicate when found class is not a dataset' do
    lambda do
      @resolver.resolve(:not_a_dataset)
    end.should raise_error(
      Dataset::DatasetNotFound,
      "Found a class 'NotADataset', but it does not subclass 'Dataset::Base'."
    )
  end
  
  it 'should indicate that it could not find a dataset' do
    lambda do
      @resolver.resolve(:undefined)
    end.should raise_error(
      Dataset::DatasetNotFound,
      "Could not find a dataset 'Undefined' or 'UndefinedDataset'."
    )
  end
end

describe Dataset::DirectoryResolver do
  before do
    @resolver = Dataset::DirectoryResolver.new(SPEC_ROOT + '/fixtures/datasets')
  end
  
  it 'should not look for a file if the constant is already defined' do
    @resolver.resolve(:resolve).should be(ResolveDataset)
  end
  
  it 'should find file with exact name match' do
    defined?(ExactName).should be_nil
    dataset = @resolver.resolve(:exact_name)
    defined?(ExactName).should == 'constant'
    dataset.should == ExactName
  end
  
  it 'should find file with name ending in _dataset' do
    defined?(EndingWithDataset).should be_nil
    dataset = @resolver.resolve(:ending_with)
    defined?(EndingWithDataset).should == 'constant'
    dataset.should == EndingWithDataset
  end
  
  it 'should indicate that it could not find a dataset file' do
    lambda do
      @resolver.resolve(:undefined)
    end.should raise_error(
      Dataset::DatasetNotFound,
      %(Could not find a dataset file in ["#{SPEC_ROOT + '/fixtures/datasets'}"] having the name 'undefined.rb' or 'undefined_dataset.rb'.)
    )
  end
  
  it 'should indicate when it finds a file, but the constant is not defined after loading the file' do
    lambda do
      @resolver.resolve(:constant_not_defined)
    end.should raise_error(
      Dataset::DatasetNotFound,
      "Found the dataset file '#{SPEC_ROOT + '/fixtures/datasets/constant_not_defined.rb'}', but it did not define a dataset 'ConstantNotDefined' or 'ConstantNotDefinedDataset'."
    )
  end
  
  it 'should indicate when it finds a file, but the constant defined is not a subclass of Dataset::Base' do
    lambda do
      @resolver.resolve(:not_a_dataset_base)
    end.should raise_error(
      Dataset::DatasetNotFound,
      "Found the dataset file '#{SPEC_ROOT + '/fixtures/datasets/not_a_dataset_base.rb'}' and a class 'NotADatasetBase', but it does not subclass 'Dataset::Base'."
    )
  end
  
  it 'should support adding multiple directories' do
    @resolver << (SPEC_ROOT + '/fixtures/more_datasets')
    defined?(InAnotherDirectoryDataset).should be_nil
    dataset = @resolver.resolve(:in_another_directory)
    defined?(InAnotherDirectoryDataset).should == 'constant'
    dataset.should == InAnotherDirectoryDataset
  end
end