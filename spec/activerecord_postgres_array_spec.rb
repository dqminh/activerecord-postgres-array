require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "activerecord-postgres-array" do
  describe "migration" do
    describe "add_column" do
      let(:add_column) do
        ActiveRecord::Schema.define do
          add_column :tests, :test_array, :integer_array
        end
      end
      subject { Arel::Table.new(:tests).columns.detect {|c| c.name == :test_array}.column }

      specify { expect { add_column }.to_not raise_error }
      its(:sql_type) { should == "integer[]" }
    end
  end
end
