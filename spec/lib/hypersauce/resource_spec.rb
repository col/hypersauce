require 'spec_helper'

describe Hypersauce::Resource do

  let(:body) { '{ "attr1": "value1", "attr2": "value2", "_links": {}, "_embedded": {} }' }
  before do
    stub_request(:any, 'http://www.example.com').to_return(:body => body)
  end
  subject { Hypersauce::Resource.new(url: 'http://www.example.com') }

  describe 'attributes' do

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

      its(:attr1) { should eql 'value1' }
      its(:attr2) { should eql 'value2' }
      it { should_not respond_to :_links }
      it { should_not respond_to :_embedded }
      it 'should implement attribute writers' do
        subject.attr1.should eql 'value1'
        subject.attr1 = 'new value'
        subject.attr1.should eql 'new value'
      end

      context 'when using a subclass of Hypersauce::Resource' do
        class TestApi < Hypersauce::Resource; end
        subject { TestApi.new(url: 'http://www.example.com') }
        it { should respond_to :attr1 }
        it { should respond_to :attr2 }
        it { should respond_to :attr1= }
        it { should respond_to :attr2= }
      end

    end

  end

  describe 'links' do
    let(:self_link) { {
      href: 'http://www.example.com',
      title: 'Home'
    }}
    let(:widgets_link) { {
        href: 'http://www.example.com/widgets{?max_price}',
        title: 'Widgets Collection',
        templated: true
    }}
    let(:links) { { :self => self_link, :widgets => widgets_link } }
    let(:body) { "{ \"_links\": #{JSON.generate(links)} }" }

    it { should respond_to :links }
    its(:links) { should be_a HashWithIndifferentAccess }

    it 'should have a "self" link' do
      subject.links[:self].should_not be_nil
      subject.links[:self].should be_a Hypersauce::Link
    end

    it 'should have a "widgets" link' do
      subject.links[:widgets].should_not be_nil
      subject.links[:widgets].should be_a Hypersauce::Link
    end

  end

end