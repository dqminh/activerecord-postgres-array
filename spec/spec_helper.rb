$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'active_support'
require 'active_record'
require 'active_record/base'
require 'active_record/connection_adapters/postgresql_adapter'
require_relative '../lib/activerecord-postgres-array'
require 'rspec'
require 'rspec/autorun'
require 'pg'

ActiveRecordPostgresArray.initializers.each do |initializer|
  initializer.run
end

ActiveRecord::Base.establish_connection(
  :adapter => 'postgresql',
  :database => 'postgres',
  :encoding => 'utf8'
)
ActiveRecord::Base.connection.create_database('test_pg_array', :encoding=>'utf8') rescue nil

require 'arel'

RSpec.configure do |config|
  config.before do
    require_relative 'fixtures/schema'
  end
end
