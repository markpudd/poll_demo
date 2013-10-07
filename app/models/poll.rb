class Poll < ActiveRecord::Base
  has_many :answers
  attr_accessible :question, :sfid
end
