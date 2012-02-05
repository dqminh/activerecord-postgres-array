require "spec_helper"

describe "Supports for data types" do
  let(:test_table) { :tests }
  let(:column_name) { :test_array }

  let(:add_column) do
    t = test_table
    c = column_name
    d = column_type
    ActiveRecord::Schema.define do
      add_column t, c, d
    end
  end

  subject { add_column; Arel::Table.new(test_table).columns.detect { |c| c.name == column_name }.column }

  after { ActiveRecord::Base.connection.execute "drop table #{test_table};" }

  describe :integer_array do
    let(:column_type) { :integer_array }

    its(:sql_type) { should == "integer[]" }
    its(:type) { should == column_type }
  end

  describe :string_array do
    let(:column_type) { :string_array }

    its(:sql_type) { should == "character varying[]" }
    its(:type) { should == column_type }
  end

  describe :decimal_array do
    let(:column_type) { :decimal_array }

    its(:sql_type) { should == "numeric[]" }
    its(:type) { should == column_type }
  end
end
