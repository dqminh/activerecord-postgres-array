module ActiveRecord
  class ArrayTypeMismatch < ActiveRecord::ActiveRecordError
  end

  module ConnectionAdapters
    class PostgreSQLAdapter < AbstractAdapter
      POSTGRES_ARRAY_TYPES = %w( string text integer float decimal datetime timestamp time date binary boolean )

      def native_database_types_with_array
        native_types = native_database_types_without_array
        array_types = POSTGRES_ARRAY_TYPES.inject(Hash.new) do |h, t|
          singular_type = native_types[t.to_sym]
          h.update "#{t}_array".to_sym => { :name => "#{singular_type[:name]} ARRAY" } if singular_type[:name]
        end
        native_types.merge array_types
      end
      alias_method_chain :native_database_types, :array

      # Quotes a value for use in an SQL statement
      def quote_with_array(value, column = nil)
        if value && column && column.sql_type =~ /\[\]$/
          raise ArrayTypeMismatch, "#{column.name} must have a Hash or a valid array value (#{value})" unless value.kind_of?(Array) || value.valid_postgres_array?
          return value.to_postgres_array
        end
        quote_without_array(value,column)
      end
      alias_method_chain :quote, :array
    end

    class TableDefinition
      # Adds array type for migrations. So you can add columns to a table like:
      #   create_table :people do |t|
      #     ...
      #     t.string_array :real_energy
      #     t.decimal_array :real_energy, :precision => 18, :scale => 6
      #     ...
      #   end
      PostgreSQLAdapter::POSTGRES_ARRAY_TYPES.each do |column_type|
        define_method("#{column_type}_array") do |*args|
          options = args.extract_options!
          base_type = @base.type_to_sql(column_type.to_sym, options[:limit], options[:precision], options[:scale])
          column_names = args
          column_names.each { |name| column(name, "#{base_type}[]", options) }
        end
      end
    end

    class PostgreSQLColumn < Column
      # Does the type casting from array columns using String#from_postgres_array or Array#from_postgres_array.
      def type_cast_code_with_array(var_name)
        if type.to_s =~ /_array$/
          base_type = type.to_s.gsub(/_array/, '')
          "#{var_name}.from_postgres_array(:#{base_type})"
        else
          type_cast_code_without_array(var_name)
        end
      end
      alias_method_chain :type_cast_code, :array


      # Adds the array type for the column.
      def simplified_type_with_array(field_type)
        if field_type =~ /^numeric.+\[\]$/
          :decimal_array
        elsif field_type =~ /\[\]$/
          type = field_type.gsub /\[\]/, ""
          data_type = simplified_type_without_array(type)
          "#{data_type}_array".to_sym
        else
          simplified_type_without_array(field_type)
        end
      end
      alias_method_chain :simplified_type, :array

      class << self
        def extract_value_from_default_with_array(default)
          case default
            when /\A'(.*)'::(?:(.*)\[\])\z/m
              $1.from_postgres_array $2.to_sym
            else
              extract_value_from_default_without_array default
          end
        end
        alias_method_chain :extract_value_from_default, :array
      end
    end
  end
end
