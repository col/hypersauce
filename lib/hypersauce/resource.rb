require 'faraday'
require 'json'
require 'active_support/core_ext/hash/indifferent_access'
require_relative 'link'

module Hypersauce
  class Resource

    attr_reader :url

    def initialize(options)
      @url = options[:url]
      create_attribute_accessors
      create_link_accessors
    end

    def attributes
      @attributes ||= begin
        attributes = response_data.dup.delete_if { |key| key == '_links' || key == '_embedded' }
        HashWithIndifferentAccess.new(attributes)
      end
    end

    def links
      @links ||= begin
        links = HashWithIndifferentAccess.new()
        response_data.fetch('_links', {}).each_pair do |key, value|
          links[key] = Hypersauce::Link.new(value)
        end
        links
      end
    end

    def method_missing(meth, *args, &block)
      if meth.to_s =~ /(.*?)=/
        attributes[$1] = args[0]
      elsif attributes.has_key? meth
        attributes[meth]
      elsif links.has_key? meth
        follow_link(meth.to_sym, args[0])
      else
        super
      end
    end

    def follow_link(link_sym, options = {})
      link = links[link_sym]
      return nil unless link
      Hypersauce::Resource.new(url: link.href(options))
    end

    private

    def create_attribute_accessors
      if self.class.to_s == 'Hypersauce::Resource'
        puts 'Cannot define attribute methods directly on Hypersauce::Resource. Will use method_missing unless you define a subclass.'
        return
      end

      attributes.keys.each do |key|
        attr_sym = key.to_sym
        attr_set_sym = "#{key}=".to_sym
        self.class.send(:define_method, attr_sym) do
          self.attributes[attr_sym]
        end
        self.class.send(:define_method, attr_set_sym) do |value|
          self.attributes[attr_sym] = value
        end
      end
    end

    def create_link_accessors
      if self.class.to_s == 'Hypersauce::Resource'
        puts 'Cannot define link methods directly on Hypersauce::Resource. Will use method_missing unless you define a subclass.'
        return
      end

      links.each do |link_key, link|
        self.class.send(:define_method, link_key.to_sym) do |*args|
          follow_link(link_key.to_sym, args[0])
        end
      end
    end

    def response_data
      @response ||= begin
        connection = Faraday.new(url: @url)
        response = connection.get('')
        JSON.parse(response.body)
      end
    end

  end
end