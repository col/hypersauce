require 'spec_helper'

describe Hypersauce::Link do

  let(:href) { 'http://www.example.com/widgets' }
  let(:title) { 'Widgets Collection' }
  let(:templated) { false }
  let(:attributes) { { href: href, title: title, templated: templated } }
  let(:link) { Hypersauce::Link.new(attributes) }
  subject { link }

  it { should respond_to :attributes }
  its(:attributes) { should be_a HashWithIndifferentAccess }

  it { should respond_to :href }
  it { should respond_to :title }
  it { should respond_to :templated? }

  describe '#href' do
    context 'when not templated' do
      its(:href) { should eql href }
    end
    context 'when templated' do
      let(:templated) { true }
      it 'should respond with a templated href' do
        result = double(:templated_link)
        options = double(:options)
        subject.should_receive(:templated_href).with(options).and_return(result)
        subject.href(options).should eql result
      end
    end
  end

  describe '#templated_href' do
    let(:attributes) { { href: 'http://www.example.com/{resource}/search{?q}', templated: true } }
    it 'should substitute template values' do
      subject.send(:templated_href, resource: 'widgets', q: 'new').should == 'http://www.example.com/widgets/search?q=new'
    end
  end

end