$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'mongo_mapper'
require 'pp'

MongoMapper.database = 'testing'

class Field
  include MongoMapper::EmbeddedDocument
  key :name
  validates_presence_of :name
end

class KField
  include MongoMapper::EmbeddedDocument
  key :name
  
  def self.__hack__no_callbacks() true; end
end

class Template
  include MongoMapper::Document
  key :name
  many :fields
  many :k_fields

  # This tells the template to validate all
  # fields when validating the template.
  validates_associated :fields
end

# Name is missing on embedded field
template = Template.new(:fields => [Field.new])
puts template.valid? # false

# Name is present on embedded field
template = Template.new(:fields => [Field.new(:name => 'Yay')])
puts template.valid? # true

# Stack level too deep occurrs with 1000 embedded documents, even when they don't have callbacks or validations.
# But you can use our little hack (above) to get around this...
1000.times { template.k_fields << KField.new(:name => "K") }
puts "can we save without overlfowing the stack? #{template.save}"