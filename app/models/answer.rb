class Answer < ActiveRecord::Base
  belongs_to :poll
  has_many :votes
  attr_accessible :answer_text
end
