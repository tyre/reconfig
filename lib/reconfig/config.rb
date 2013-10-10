module Reconfig
  class Config
    attr_accessor :meta_key, :options

    def initialize(opts={})
      @meta_key = opts.delete(:meta_key) || 'reconf:_meta'
      @options = {
        :default_namespace => :default,
        :prefix => 'reconf:'
      }.merge(opts)
    end

    def [](key)
      namespaces[default_namespace][key]
    end

    def []=(key, value)
      namespaces[default_namespace][key] = value
    end

    def register_namespaces(*namespace_names)
      namespace_names.each do |namespace_name|
        register_namespace namespace_name
      end
    end

    def namespaces
      @namespaces ||= begin
        default_namespace_key = namespace_key(default_namespace)
        default_namespace = Namespace.new(default_namespace_key)
        { options[:default_namespace].to_sym => default_namespace }
      end
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

    def redis_client
      @redis_client ||= RedisClient.new
    end

    def type_mapper
      @type_mapper ||= TypeMapper.new
    end

    def default_namespace
      options[:default_namespace]
    end

    def register_namespace(namespace_name)
      namespace_key = namespace_key(namespace_name)
      redis_client.sadd(meta_key, namespace_key)
      namespaces[namespace_name.to_sym] = Namespace.new(namespace_key)
    end

    def namespace_key(namespace_name)
      options[:prefix] + namespace_name.to_s
    end
  end
end