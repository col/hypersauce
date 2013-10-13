require 'faraday'
require 'json'
require 'active_support/core_ext/hash/indifferent_access'

module Hypersauce
  class Resource

    def initialize(options)
      @url = options[:url]
    end

    def attributes
      @attributes ||= begin
        attributes = response_data.dup.delete_if { |key| key == '_links' || key == '_embedded' }
        HashWithIndifferentAccess.new(attributes)
      end
    end

    private

    def response_data
      @response ||= begin
        connection = Faraday.new(url: @url)
        response = connection.get('')
        JSON.parse(response.body)
      end
    end

  end
end