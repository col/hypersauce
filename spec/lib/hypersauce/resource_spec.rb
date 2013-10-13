require 'spec_helper'

describe Hypersauce::Resource do

  describe 'attributes' do
    before do
      stub_request(:any, 'http://www.example.com').to_return(:body => '{ "attr1": "value1", "attr2": "value2", "_links": {}, "_embedded": {} }')
    end
    subject { Hypersauce::Resource.new(url: 'http://www.example.com') }

    it { should respond_to :attributes }
    it 'should have 2 attributes' do
      subject.attributes.count.should == 2
    end
    it 'should accept a string attribute key' do
      subject.attributes['attr1'].should == 'value1'
    end
    it 'should accept a symbol attribute key' do
      subject.attributes[:attr1].should == 'value1'
    end
    it 'should not include "_links"' do
      subject.attributes.should_not have_key '_links'
    end
    it 'should not include "_embedded"' do
      subject.attributes.should_not have_key '_embedded'
    end

    describe 'attribute accessors' do

      context 'when using Hypersauce::Resource directly' do
        its(:attr1) { should eql 'value1' }
        its(:attr2) { should eql 'value2' }
        it { should_not respond_to :_links }
        it { should_not respond_to :_embedded }
      end

      context 'when using a subclass of Hypersauce::Resource' do
        class TestApi < Hypersauce::Resource; end
        subject { TestApi.new(url: 'http://www.example.com') }
        it { should respond_to :attr1 }
        it { should respond_to :attr2 }
        its(:attr1) { should eql 'value1' }
        its(:attr2) { should eql 'value2' }
        it { should_not respond_to :_links }
        it { should_not respond_to :_embedded }
      end

    end

  end

end