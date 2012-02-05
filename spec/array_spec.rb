require_relative "../lib/activerecord-postgres-array/array"

describe Array do
  describe "#to_postgres_array" do
    context 'when array contains fixnums' do
      subject { [10,10].to_postgres_array }
      it { should == "'{10, 10}'" }
    end
  end
end
