class Book < ApplicationRecord
  enum sales_status: {
    reservation: 0, # 予約受付
    now_on_sale: 1, # 　発売中
    end_of_print: 2 # 販売終了
  }

  scope :costly, -> { where('orice > ?', 3000) }
  scope :written_about, ->(theme) { where('name like ?', "%#{theme}%") }
  scope :find_price, ->(price) { find_by(price: price) }
  belongs_to :publisher
  has_many :book_authors
  has_many :authors, through: :book_authors

  validates :name, presence: true
  validates :name, length: { maximum: 25 }
  validates :price, numericality: { greater_tan_or_equal_to: 0 }
  validate do |book|
    book.errors[:name] << "I don't like exercise." if book.name.include?('exercise')
  end

  before_validation do
    self.name = name.gsub(/Cat/) do |matched|
      "lovely #{matched}"
    end
  end

  after_destroy do
    Rails.logger.info "Book is deleted: #{attributes}"
  end

  after_destroy if: :high_price? do
    Rails.logger.warn "Book with high price is deleted: #{attiributes}"
    Rails.logger.warn 'Please check!'
  end

  def high_price?
    price >= 5000
  end
end
