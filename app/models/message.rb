# == Schema Information
#
# Table name: messages
#
#  id         :bigint           not null, primary key
#  body       :text
#  role       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  quiz_id    :integer
#
class Message < ApplicationRecord
  belongs_to :quiz
  validates :role, inclusion: { in: [ "system", "user", "assistant" ] }
  validates :role, presence: true
  validates :body, presence: true
end
