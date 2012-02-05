require "spec_helper"

describe "ActiveRecord" do

  describe "Model" do
    let(:klass) do
      test = Class.new(ActiveRecord::Base)
      test.set_table_name test_table
      test
    end
    let(:test_table) { :create_table }
    let(:string_arr) { get_column :string_arr }
    let(:integer_arr) { get_column :integer_arr }

    let(:create_table) do
      t = test_table
      ActiveRecord::Schema.define do
        create_table t do |t|
          t.integer_array :integer_arr, default: []
          t.string_array :string_arr, default: []
        end
      end
      Arel::Table.new(test_table).columns
    end

    before { create_table }
    after { ActiveRecord::Base.connection.execute "drop table #{test_table};" }

    describe "#save" do
      subject { klass.new integer_arr: [1, 2], string_arr: %w(hello world) }

      its(:integer_arr) { should == [1, 2] }
      its(:string_arr) { should == %w(hello world) }
      specify { expect { subject.save }.to change { klass.count }.by(1) }
    end

    describe ".create" do
      subject { klass.create integer_arr: [1, 2], string_arr: %w(hello world) }
      specify { expect { subject }.to change { klass.count }.by(1) }
    end
  end

  describe "Migration" do
    after { ActiveRecord::Base.connection.execute "drop table #{test_table};" }

    def get_column(name)
      subject.detect { |c| c.name == name }.column
    end

    describe "create_table" do
      let(:test_table) { :create_table }
      let(:string_arr) { get_column :string_arr }
      let(:integer_arr) { get_column :integer_arr }

      let(:create_table) do
        t = test_table
        ActiveRecord::Schema.define do
          create_table t do |t|
            t.integer_array :integer_arr
            t.string_array :string_arr
          end
        end
        Arel::Table.new(test_table).columns
      end

      subject { create_table }

      specify {
        string_arr.type.should == :string_array
        string_arr.sql_type.should == "character varying(255)[]"
      }

      specify {
        integer_arr.type.should == :integer_array
        integer_arr.sql_type.should == "integer[]"
      }
    end

    describe "default value" do
      describe :create_table do
        let(:test_table) { :people }
        let(:create_table) do
          t = test_table
          ActiveRecord::Schema.define do
            create_table t do |t|
              t.integer_array :test_array, default: [1]
            end
          end
        end

        subject do
          create_table
          Arel::Table.new(test_table).columns.detect { |c| c.name == :test_array }.column
        end

        specify { expect { create_table }.to_not raise_error }
        its(:default) { should == [1] }
      end

      describe :add_column do
        let(:test_table) { :tests }
        let(:add_column) do
          t = test_table
          d = default_value
          ct = column_type
          ActiveRecord::Schema.define do
            add_column t, :test_array, ct, default: d
          end
        end

        subject do
          add_column
          Arel::Table.new(test_table).columns.detect { |c| c.name == :test_array }.column
        end

        context "empty array" do
          let(:default_value) { '{}' }
          let(:column_type) { :integer_array }
          its(:default) { should == [] }
        end

        context "array of integer value" do
          let(:default_value) { '{1,2}' }
          let(:column_type) { :integer_array }
          its(:default) { should == [1, 2] }
        end

        context "array of string value" do
          let(:default_value) { '{"hello", "world"}' }
          let(:column_type) { :string_array }
          its(:default) { should =~ %w(hello world) }
        end
      end
    end
  end
end
