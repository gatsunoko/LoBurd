class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  validates :username, presence: { message: 'ユーザー名は必須です'},
  						 uniqueness: { message: 'このユーザー名は既に使用されています。'}
  validates :password, presence: { message: 'パスワードは必須です'},
  						 length: {minimum: 6, message: 'パスワードは6文字以上です。'}

  def email_required?
    false
  end
end
