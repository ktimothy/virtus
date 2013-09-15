module Virtus
  class Attribute

    # Hash
    #
    # @example
    #   class Post
    #     include Virtus
    #
    #     attribute :meta, Hash
    #   end
    #
    #   Post.new(:meta => { :tags => %w(foo bar) })
    #
    class Hash < Attribute
      primitive ::Hash
      default   primitive.new

      # @api private
      def self.build_type(primitive, options)
        type_options = infer_options(primitive)

        Axiom::Types.infer(primitive).new do
          key_type   type_options.fetch(:key_type,   Axiom::Types::Object)
          value_type type_options.fetch(:value_type, Axiom::Types::Object)
        end
      end

      # Handles hashes with [key_type => value_type] syntax
      #
      # @param [Class] type
      #
      # @param [Hash] options
      #
      # @return [Hash]
      #
      # @api private
      def self.infer_options(type)
        options = {}

        if !type.respond_to?(:size)
          options
        elsif type.size > 1
          raise ArgumentError, "more than one [key => value] pair in `#{type.inspect}`"
        else
          key_type, value_type = type.first

          options.merge!(
            :key_type   => Axiom::Types.infer(key_type),
            :value_type => Axiom::Types.infer(value_type)
          )
        end

        options
      end

      # @api private
      def self.merge_options!(type, options)
        super

        unless options.key?(:key_type)
          options[:key_type] = Attribute.build(type.key_type)
        end

        unless options.key?(:value_type)
          options[:value_type] = Attribute.build(type.value_type)
        end
      end

      # @api public
      def coerce(input)
        coerced = super

        return coerced unless coerced.respond_to?(:each_with_object)

        coerced.each_with_object({}) do |(key, value), hash|
          hash[key_type.coerce(key)] = value_type.coerce(value)
        end
      end

      # @api private
      def key_type
        @options[:key_type]
      end

      # @api private
      def value_type
        @options[:value_type]
      end

    end # class Hash
  end # class Attribute
end # module Virtus
