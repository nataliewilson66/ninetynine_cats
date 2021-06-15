require 'action_view'

class Cat < ApplicationRecord
  include ActionView::Helpers::DateHelper

  validates :name, :sex, :color, :birth_date, presence: true
  validates :color, inclusion: { in: %w(White Black Orange), message: "%{value} is not a valid color" }
  validates :sex, inclusion: { in: %w(M F), message: "%{value} is not a valid sex" }

  has_many :rental_requests, dependent: :destroy,
    class_name: 'CatRentalRequest',
    foreign_key: :cat_id,
    primary_key: :id

  def age
    distance_of_time_in_words(Date.today, birth_date)
  end
end