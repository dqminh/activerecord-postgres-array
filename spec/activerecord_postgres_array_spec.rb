require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "activerecord-postgres-array" do
  describe "migration" do
    after { ActiveRecord::Base.connection.execute "drop table #{test_table};" }

    describe "default value" do
      let(:test_table) { :tests }
      let(:add_column) do
        t = test_table
        d = default_value
        ActiveRecord::Schema.define do
          add_column t, :test_array, :integer_array, default: d
        end
      end

      context "empty array" do
        let(:default_value) { '{}' }
        subject do
          add_column
          Arel::Table.new(test_table).columns.detect { |c| c.name == :test_array }.column
        end

        its(:default) { should == [] }
      end

      context "non-empty array" do
        let(:default_value) { '{1,2}' }
        subject do
          add_column
          Arel::Table.new(test_table).columns.detect { |c| c.name == :test_array }.column
        end

        its(:default) { should == [1,2] }
      end
    end

    describe "add_column" do
      let(:test_table) { :tests }

      let(:add_column) do
        t = test_table
        ActiveRecord::Schema.define do
          add_column t, :test_array, :integer_array
        end
      end

      subject do
        add_column
        Arel::Table.new(test_table).columns.detect { |c| c.name == :test_array }.column
      end

      specify { expect { add_column }.to_not raise_error }
      its(:sql_type) { should == "integer[]" }
      its(:type) { should == :integer_array }
    end

    describe "create_table" do
      let(:test_table) { :people }
      let(:create_table) do
        t = test_table
        ActiveRecord::Schema.define do
          create_table t do |t|
            t.integer_array :test_array
          end
        end
      end

      subject do
        create_table
        Arel::Table.new(test_table).columns.detect { |c| c.name == :test_array }.column
      end

      specify { expect { create_table }.to_not raise_error }
      its(:sql_type) { should == "integer[]" }
    end

    describe "create_table with default" do
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
  end

  describe Array do
    describe "#to_postgres_array" do
      context 'when array contains fixnums' do
        subject { [10,10].to_postgres_array }
        it { should == "'{10, 10}'" }
      end
    end
  end

  describe String do
    describe "#from_postgres_array" do
      context "when empty array" do
        subject { "{}".from_postgres_array }
        it { should == [] }
      end

      it "should infer interger type" do
        "{1}".from_postgres_array(:integer).should == [1]
      end
    end
  end
end
