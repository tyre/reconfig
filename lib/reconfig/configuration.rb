module Reconfig
  class Configuration
    attr_writer :namespaces, :meta_key, :prefix

    def namespaces
      @namespaces ||= []
    end

    def meta_key
      @meta_key ||= "#{prefix}_meta"
    end

    def prefix
      @prefix ||= 'reconf:'
    end
  end
end