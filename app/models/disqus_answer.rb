class DisqusAnswer < ActiveRecord::Base
  belongs_to :disqus_forum_comment
  belongs_to :answer
end
