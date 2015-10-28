class User < ActiveRecord::Base
  validates :auth_token, uniqueness: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # remove registerable - let User COntroller create
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable
  # validate auth token is unique

  before_create :generate_authentication_token!

  def generate_authentication_token!
    begin
      aut = Devise.friendly_token
      puts "generate token" + aut
      self.auth_token = aut
    end while self.class.exists?(auth_token: auth_token)
  end
end
