# == Schema Information
#
# Table name: quizzes
#
#  id         :bigint           not null, primary key
#  topic      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Quiz < ApplicationRecord
end
