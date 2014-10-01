# Component as mixin
module Moon
  module Component
    @@component_list = {}

    def self.[](key)
      @@component_list[key]
    end

    def self.fetch(key)
      @@component_list.fetch(key)
    end

    def self.list
      @@component_list
    end

    module ClassMethods

      attr_reader :registered

      def field(name, data)
        (@fields ||= {})[name] = data

        attr_reader name unless method_defined?(name)
        attr_writer name unless method_defined?(name.to_s+"=")
        name
      end

      def fields
        @fields ||= {}
        if superclass.respond_to?(:fields)
          superclass.fields.merge(@fields)
        else
          @fields
        end
      end

      def register(sym)
        # of course we'd like something prettier... -,-
        Component.list.delete(@registered) if @registered
        @registered = sym
        Component.list[sym] = self
      end
    end

    module InstanceMethods
      def initialize(options={})
        setup(options)
      end

      def setup(options={})
        self.class.fields.each do |key, data|
          send("#{key}=", data[:default]) if data.key?(:default)
          send("#{key}=", options[key]) if options.key?(key)
        end
      end

      def to_h # predefine to_h for fields
        self.class.fields.inject({}) do |result, keyval| # res, (k, v) doesn't work?!
          (key, data) = *keyval
          result[key] = self.send(key)
          result
        end
      end

      def export
        to_h.merge(component_type: self.class.registered).stringify_keys
      end

      def import(data)
        setup(data)
        self
      end

      private :setup
    end

    def self.included(mod)
      mod.extend         ClassMethods
      mod.send :include, InstanceMethods
      mod.register mod.to_s.demodulize.downcase.to_sym
    end

    def self.load(data)
      self[data["component_type"].to_sym].new(data.symbolize_keys)
    end
  end
end
