# frozen_string_literal: true

# * Here you must define your `Factory` class.
# * Each instance of Factory could be stored into variable. The name of this variable is the name of created Class
# * Arguments of creatable Factory instance are fields/attributes of created class
# * The ability to add some methods to this class must be provided while creating a Factory
# * We must have an ability to get/set the value of attribute like [0], ['attribute_name'], [:attribute_name]
#
# * Instance of creatable Factory class should correctly respond to main methods of Struct
# - each
# - each_pair
# - dig
# - size/length
# - members
# - select
# - to_a
# - values_at
# - ==, eql?

class Factory
  class << self
    def new(*args, &block)
      const_set(args.shift.capitalize, create_new_class(*args, &block)) if args.first.is_a?(String)
      create_new_class(*args, &block)
    end

    def create_new_class(*args, &block)
      Class.new do
        attr_accessor(*args)

        define_method :initialize do |*variables|
          raise ArgumentError, "Expected #{args.count}" if args.count != variables.count

          args.each_index do |index|
            instance_variable_set("@#{args[index]}", variables[index])
          end
        end

        define_method :each do |&block|
          values.each(&block)
        end

        define_method :each_pair do |&pair|
          to_h.each_pair(&pair)
        end

        define_method :dig do |*args|
          args.inject(self) { |values, args| values[args] if values }
        end

        define_method :to_h do
          args.zip(values).to_h
        end

        define_method :length do
          args.size
        end

        define_method :members do
          args
        end

        define_method :select do |&block|
          values.select(&block)
        end

        define_method :eql? do |other|
          self.class == other.class && values == other.values
        end

        define_method(:to_a) do
          instance_variables.map { |argument| instance_variable_get(argument) }
        end

        define_method(:values_at) do |*index|
          instance_variables.values_at(*index).map do |values|
            instance_variable_get values
          end
        end

        define_method :[] do |argument|
          argument.is_a?(Integer) ? values[argument] : instance_variable_get("@#{argument}")
        end

        define_method :[]= do |argument, value|
          instance_variable_set("@#{argument}", value)
        end

        alias_method :values, :to_a
        alias_method :size, :length
        alias_method :==, :eql?

        class_eval(&block) if block_given?
      end
    end
  end
end
