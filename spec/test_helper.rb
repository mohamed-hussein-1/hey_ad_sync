require 'minitest/autorun'
require 'webmock'
require 'webmock/minitest'
require 'active_record'
require 'database_cleaner'

WebMock.enable!
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3", :database => ':memory:'
)
ActiveRecord::Schema.define(version: 1) do
  create_table :campaigns do |t|
    t.bigint    :job_id
    t.bigint   :external_reference_id
    t.integer   :status
    t.text :description
  end
end

DatabaseCleaner.strategy = :transaction
