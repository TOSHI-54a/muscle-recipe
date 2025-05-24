class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[google_oauth2]
  has_many :search_recipes, dependent: :destroy
  has_many :chat_room_users, dependent: :destroy
  has_many :chat_rooms, through: :chat_room_users
  has_many :likes, dependent: :destroy
  has_many :liked_search_recipes, through: :likes, source: :search_recipe
  has_many :search_logs, dependent: :destroy
  has_many :messages, dependent: :destroy

  validates :name, presence: true, length: { maximum: 20 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :age, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 120 }, allow_nil: true
  validates :height, numericality: { only_integer: true, greater_than: 50, less_than_or_equal_to: 250 }, allow_nil: true
  validates :weight, numericality: { only_integer: true, greater_than: 10, less_than_or_equal_to: 150 }, allow_nil: true
  validates :gender, inclusion: { in: %w[male female], message: "%{value} は選択できません" }, allow_blank: true

  def self.from_omniauth(auth)
    user = find_by(email: auth.info.email)

    if user
      user.update(provider: auth.provider, uid: auth.uid) if user.provider.blank? || user.uid.blank?
      return user
    end
    create(
      name: auth.info.name,
      email: auth.info.email,
      provider: auth.info.provider,
      uid: auth.uid,
      password: Devise.friendly_token[0, 20]
    )
  end

  def self.create_unique_string
    SecureRandom.uuid
  end
end
