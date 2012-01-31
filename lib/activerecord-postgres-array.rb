require 'rails'

class ActiveRecordPostgresArray < Rails::Railtie

  initializer 'activerecord-postgres-array' do
    ActiveSupport.on_load :active_record do
      require_relative "./activerecord-postgres-array/activerecord"
    end
  end
end

require_relative "./activerecord-postgres-array/string"
require_relative "./activerecord-postgres-array/array"
