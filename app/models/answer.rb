class Answer < ActiveRecord::Base
  belongs_to :poll
  attr_accessible :answer_text
end
