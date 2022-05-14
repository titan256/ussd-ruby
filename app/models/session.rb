class Session < ApplicationRecord
  has_many :hops

  def last_hop
    Hop.where(session: self).last
  end
end
