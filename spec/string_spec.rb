require_relative "../lib/activerecord-postgres-array/string"

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
