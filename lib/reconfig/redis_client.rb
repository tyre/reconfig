require 'redis'
module Reconfig
  class RedisClient

    def fetch_by_type(key, stored_type)
      case stored_type
        when type_mapper.string
          connection.get(key)
        when type_mapper.integer
          connection.get(key).to_i
        when type_mapper.float
          connection.get(key).to_f
        when type_mapper.hash
          connection.hgetall(key)
        when type_mapper.list
          connection.lrange(key, 0, -1)
        when type_mapper.set
          connection.smembers(key)
        else
          raise UnknownTypeException.new("#{stored_type} is not a valid type.")
      end
    end

    # Overwrites associated value
    def set_by_type(key, value)
      case type_mapper.stored_type(value)
        when type_mapper.string, type_mapper.integer, type_mapper.float
          connection.set(key, value)
        when type_mapper.hash
          connection.del key
          connection.hmset(key, *value.to_a.flatten)
        when type_mapper.list
          connection.del key
          connection.rpush key, *value
        when type_mapper.set
          connection.del key
          connection.sadd key, *value
        else
          raise UnknownTypeException.new("Unable to store type #{value.class.name}.")
      end
    end

    def respond_to?(method)
      connection.respond_to?(method) || super
    end

    def method_missing(method, *args, &block)
      if connection.respond_to?(method)
        return connection.send(method, *args, &block)
      end
      super
    end

    private

    def connection
      connection = Redis.new
    end

    def type_mapper
      TypeMapper.new
    end
  end
end

class UnknownTypeException < Exception; end