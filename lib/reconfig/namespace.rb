module Reconfig
  class Namespace

    attr_accessor :meta_key, :options

    def initialize(meta_key, opts={})
      @meta_key = meta_key
      @options = {
        prefix: meta_key + ':'
      }.merge opts
    end

    def config
      @config ||= refresh_config
    end

    def refresh
      refresh_keyspace
      refresh_config
    end

    def [](key)
      config[key]
    end

    def []=(key, value)
      set(key, value)
      config[key] = value
    end

    private

    def key_space
      @keyspace ||= refresh_keyspace
    end

    def refresh_keyspace
      @keyspace = redis_client.zrange(meta_key, 0, -1, with_scores: true)
    end

    def refresh_config
      @config = key_space.reduce({}) do |config_hash, (stored_key, value_type)|
        namespaced_key = namespaced_key(stored_key)
        config_hash[stored_key] = redis_client.fetch_by_type(namespaced_key, value_type)
        config_hash
      end
    end

    def set(key, value)
      stored_type = type_mapper.stored_type(value)
      redis_client.set_by_type(namespaced_key(key), value)
      redis_client.zadd(meta_key, stored_type, key)
    end

    def namespaced_key(key)
      options[:prefix] + key.to_s
    end

    def redis_client
      @redis_client ||= RedisClient.new
    end

    def type_mapper
      @type_mapper ||= TypeMapper.new
    end

  end
end