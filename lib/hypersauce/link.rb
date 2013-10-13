require 'active_support/core_ext/hash/indifferent_access'
require 'addressable/template'

module Hypersauce
  class Link

    attr_accessor :attributes

    def initialize(attribs)
      @attributes = HashWithIndifferentAccess.new(attribs)
    end

    def href(options = {})
      templated? ? templated_href(options) : attributes[:href]
    end

    def title
      attributes[:title]
    end

    def templated?
      attributes[:templated]
    end

    private

    def templated_href(options = {})
      template = Addressable::Template.new(attributes[:href])
      template.expand(options).to_s
    end

  end
end