module Moon
  module DataModel
    module TypeValidators
      module Verbose
        include Moon::DataModel::TypeValidators::Base

        def check_array_content(type, key, value, options = {})
          value.each_with_index do |obj, i|
            unless type.any? { |t| check_type(t, key, obj, quiet: true, allow_nil: false) }
              str = type.map { |s| s.inspect }.join(", ")
              if options[:quiet]
                return false
              else
                raise TypeError,
                      "[#{key}[#{i}]] wrong content type #{obj.class.inspect} (expected #{str})"
              end
            end
          end
          true
        end

        def check_array_type(type, key, value, options = {})
          check_object_class(key, Array, value, options)
          check_array_content(type, key, value, options)
        end

        def check_hash_content(type, key, value, options = {})
          key_types = type.keys
          key_str = type.map { |s| s.inspect }.join(", ")
          value.each do |k, v|
            unless type.key?(k.class)
              if options[:quiet]
                return false
              else
                raise TypeError, "[#{key}] wrong Hash key (#{k}) of type #{k.class.inspect} (expected #{key_str})"
              end
            end
            value_type = type[k.class]
            check_type(value_type, "#{key}[#{k.inspect}]", v, options)
          end
        end

        def check_hash_type(type, key, value, options = {})
          check_object_class(key, Hash, value, options)
          check_hash_content(type, key, value, options)
        end

        def check_normal_type(type, key, value, options = {})
          check_object_class(key, type, value, options)
          true
        end

        def check_type(type, key, value, options={})
          if options[:allow_nil] && value.nil?
            return true
          elsif !options[:allow_nil] && value.nil?
            if options[:quiet]
              return false
            else
              raise TypeError, ":#{key} shall not be nil (expected #{type})"
            end
          end
          # validate that obj is an Array and contains correct types
          if type.is_a?(Array)
            check_array_type(type, key, value, options)
          # validate that value is a Hash of key type and value type
          elsif type.is_a?(Hash)
            check_hash_type(type, key, value, options)
          # validate that value is of type
          elsif type.is_a?(Module)
            check_normal_type(type, key, value, options)
          else
            true
          end
        end

        private :check_hash_content
        private :check_hash_type
        private :check_array_content
        private :check_array_type
        private :check_normal_type

        extend self
      end
    end
  end
end
