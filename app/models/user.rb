class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[google_oauth2]
  has_many :search_recipes, dependent: :destroy
  has_many :chat_room_users, dependent: :destroy
  has_many :chat_rooms, through: :chat_room_users, dependent: :destroy
    validates :name, presence: true, length: { maximum: 20 }
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :age, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 120 }, allow_nil: true
    validates :height, numericality: { only_integer: true, greater_than: 50, less_than_or_equal_to: 250 }, allow_nil: true
    validates :weight, numericality: { only_integer: true, greater_than: 10, less_than_or_equal_to: 150 }, allow_nil: true
    validates :gender, inclusion: { in: %w[male female], message: "%(value) は無効です" }, allow_nil: true
    # validates :uid, presence: true, uniquness: { scope: :provider }, if: -> { uid.present? }

    def self.from_omniauth(auth)
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.name = auth.info.name
        user.email = auth.info.email
        user.password = Devise.friendly_token[0, 20]
      end
    end

    def self.create_unique_string
      SecureRandom.uuid
    end
end
