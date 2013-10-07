module Reconfig
  class Namespace

    attr_accessor :meta_key

    def initializer(meta_key)
      @meta_key = meta_key
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
    end

    private

    def key_space
      @keyspace ||= refresh_keyspace
    end

    def refresh_keyspace
      @keyspace = connection.zrange(meta_key, 0, -1, with_scores: true)
    end

    def refresh_config
      config = key_space.reduce({}) do |config_hash, (stored_key, value_type)|
        config_hash[stored_key] = connection.fetch_by_type(stored_key, value_type)
        config_hash
      end
    end

    def set(key, value)
      stored_type = type_mapper.stored_type(value)
      connection.set_by_type(key, value)
      connection.zadd(meta_key, stored_type, key)
    end

    def connection
      @connection ||= RedisClient.new
    end

    def type_mapper
      @type_mapper ||= TypeMapper.new
    end

  end
end