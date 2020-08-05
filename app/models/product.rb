class Product < ApplicationRecord
  belongs_to :user, foreign_key: "user_id"
  belongs_to :category
  has_many :images, dependent: :destroy
  belongs_to :buyer, class_name: "User"
  has_many :likes
  has_many :like_users, through: :likes, source: :user

  def like_user(user_id)
    likes.find_by(user_id: user_id)
  end

  scope :with_keywords, -> keywords {
    if keywords.present?
      columns = [:name, :brand]
      where(keywords.to_s.split(/[[:blank:]]+/).reject(&:empty?).map {|keyword|
        columns.map { |a| arel_table[a].matches("%#{keyword}%") }.inject(:or)
      }.inject(:or))
    end
  }

  accepts_nested_attributes_for :images, allow_destroy: true
  validates :images, presence: { message: "は1枚以上10枚以下のアップロードが必要です" }

  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to_active_hash :prefecture

  validates :name, presence: { message: "は必須です" }
  validates :detal, presence: { message: "は必須です" }
  validates :category_id, presence: { message: "を選択してください" }
  validates :condition, presence: { message: "を選択してください" }
  validates :postage, presence: { message: "を選択してください" }
  validates :prefecture_id, presence: { message: "を選択してください" }
  validates :shipping_day, presence: { message: "を選択してください" }
  validates :price, presence: { message: "を入力してください" }

  def self.search(search)
    return Product.all unless search
    Product.where('name LIKE(?)', "%#{search}%")
  end


  scope :key, ->(search_param = nil) {
    return if search_param.blank?
    joins("INNER JOIN categories ON categories.id = products.category_id")
      .where("products.name LIKE ? OR products.brand LIKE ?  OR categories.name LIKE ? ", "%#{search_param}%", "%#{search_param}%", "%#{search_param}%")
  }
  def self.ransackable_scopes(auth_object = nil)
    %i(key)
  end
end
