require 'set'
require 'forwardable'
require 'reconfig/type_mapper'
require 'reconfig/redis_client'
require 'reconfig/namespace'
require 'reconfig/configuration'

module Reconfig
  class << self
    extend Forwardable
    delegate [:prefix, :meta_key] => :configuration

    def configure
      yield configuration if block_given?
      apply_configuration
    end

    def [](namespace)
      namespaces[namespace]
    end

    def refresh
      read_namespaces
    end

    def respond_to?(method)
      namespaces.keys.include?(method) || super
    end

    def method_missing(method, *args, &block)
      if namespaces.keys.include? method.to_sym
         return namespaces[method.to_sym]
      end

      super
    end

    private

    def configuration
      @configuration ||= Configuration.new
    end

    def redis_client
      @redis_client ||= RedisClient.new
    end

    def apply_configuration
      register_namespaces
    end

    def register_namespaces
      configuration.namespaces.each do |namespace_name|
        redis_client.sadd(meta_key, namespace_name)
      end
    end

    def namespaces
      @namespaces ||= read_namespaces
    end

    def read_namespaces
      @namespaces = begin
        redis_client.smembers(meta_key).reduce({}) do |namespaces, namespace_name|
          namespaces[namespace_name.to_sym] = Namespace.new(namespace_key(namespace_name))
          namespaces
        end
      end
    end

    def namespace_key(namespace_name)
      configuration.prefix + namespace_name.to_s
    end
  end
end