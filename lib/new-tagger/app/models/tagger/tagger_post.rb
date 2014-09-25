module Tagger
  class TaggerPost < ActiveRecord::Base
    belongs_to :user
    belongs_to :tweet, class_name: "TwitterParser::Tweet", foreign_key: "post_id"

    validates_uniqueness_of :user_id, scope: :post_id
  end
end
