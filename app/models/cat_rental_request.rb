require 'action_view'

class CatRentalRequest < ApplicationRecord
  include ActionView::Helpers::DateHelper

  validates :cat_id, :start_date, :end_date, :status, presence: true
  validates :status, inclusion: { in: %w(PENDING APPROVED DENIED), message: "%{value} is not a valid status" }
  validate :does_not_overlap_approved_request

  belongs_to :cat,
    class_name: 'Cat',
    foreign_key: :cat_id,
    primary_key: :id

  def approve!
    raise 'not pending' unless self.pending?
    transaction do
      self.status = 'APPROVED'
      self.save!

      overlapping_pending_requests.each do |req|
        req.deny!
      end
    end
  end

  def deny!
    self.status = 'DENIED'
    self.save!
  end

  def pending?
    self.status == 'PENDING'
  end

  def denied?
    self.status == 'DENIED'
  end

  private
  def overlapping_requests
    rental_requests = CatRentalRequest.where('cat_id = ? AND start_date <= ? AND end_date >= ? AND id != ?', 
                            self.cat_id, self.end_date, self.start_date, self.id)
  end

  def overlapping_approved_requests
    overlapping_requests.where('status = \'APPROVED\'')
  end

  def overlapping_pending_requests
    overlapping_requests.where('status = \'PENDING\'')
  end

  def does_not_overlap_approved_request
    return if self.denied?
    unless overlapping_approved_requests.empty?
      errors.add(:rental_request, 'can\'t overlap existing approved request')
    end
  end

end