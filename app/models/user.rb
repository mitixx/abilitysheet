# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  username               :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  iidxid                 :string           not null
#  version                :integer          default(22), not null
#  djname                 :string           not null
#  grade                  :integer
#  pref                   :integer          not null
#  role                   :integer          default(0), not null
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class User < ActiveRecord::Base
  has_many :scores, dependent: :delete_all
  has_many :logs, dependent: :delete_all
  has_many :follows, dependent: :delete_all

  devise :database_authenticatable, :registerable, :rememberable, :recoverable, :trackable, :validatable, :lockable
  attr_accessor :login

  include List
  include User::FollowMethods

  # usernameを必須・一意とする
  validates_uniqueness_of :username, :iidxid, :email
  validates_presence_of :username, :djname, :iidxid, :grade, :pref, :email

  validates :iidxid, format: {
    with: /\A\d{4}-\d{4}\z/,
    message: 'が正しくありません。'
  }, length: {
    is: 9
  }
  validates :grade, numericality: {
    only_integer: true
  }, inclusion: {
    in: Abilitysheet::Application.config.iidx_grade..18, message: 'のパラメタが異常です。'
  }
  validates :pref, numericality: {
    only_integer: true
  }, inclusion: {
    in: 0..47, message: 'のパラメタが異常です。'
  }
  validates :djname, length: { maximum: 6 }, format: { with: /\A[A-Z0-9\-\_.*!#&]+\z/, message: 'は半角大文字英字で記入して下さい' }
  validates :username, length: { maximum: 15 }, format: { with: /\A[a-z_0-9]+\z/, message: 'は半角英数字で記入して下さい' }

  scope :search_djname, ->(query) { User.where(['djname LIKE ?', "%#{PGconn.escape(query)}%"]) }

  module Special
    USERS = [1, 2, 3, 4, 5, 6, 8, 13, 16, 21, 34, 53, 63, 73, 100]
  end

  module Role
    OWNER = 100
    ADMIN = 75
    MEMBER = 50
    SPECIAL = 25
    GENERAL = 0
  end

  def owner?
    Role::OWNER <= role
  end

  def admin?
    Role::ADMIN <= role
  end

  def member?
    Role::MEMBER <= role
  end

  def special?
    Role::SPECIAL == role || Role::OWNER == role
  end

  def update_without_current_password(params, *options)
    params.delete(:current_password)
    params.delete(:password) if params[:password].blank?
    params.delete(:password_confirmation) if params[:password_confirmation].blank?

    clean_up_passwords
    update_attributes(params, *options)
  end

  class << self
    def dan
      array = []
      Static::GRADE.each.with_index(0) { |d, i| array.push([d, i]) if Abilitysheet::Application.config.iidx_grade <= i }
      array
    end

    def belongs
      array = []
      Static::PREF.each_with_index { |p, i| array.push([p, i]) }
      array
    end

    def find_first_by_auth_conditions(warden_conditions)
      conditions = warden_conditions.dup
      login = conditions.delete(:login)
      if login
        find_by('username = :value OR iidxid = :value', value: login)
      else
        find_by(conditions)
      end
    end

    def recent200
      users = ActiveRecord::Base.connection.execute('SELECT users.id, users.djname, users.iidxid, users.pref, scores.updated_at, scores.state, users.grade, sheets.title  FROM users, scores, sheets WHERE users.id = scores.user_id AND scores.state != 7 AND sheets.id = scores.sheet_id ORDER BY scores.updated_at DESC LIMIT 6400').to_a
      recent_users = []
      ret = []
      users.each do |user|
        break if 200 <= recent_users.size
        next if recent_users.include?(user['id'])
        recent_users.push(user['id'])
        user['updated_at'] = user['updated_at'].split[0]
        ret.push(user)
      end
      ret
    end

    def version_up
      User.includes(:scores).find_each do |user|
        version_up_score_create(user, user.scores)
      end
    end

    def version_up_score_create(user, scores)
      scores.each do |score|
        next if user.scores.exists?(sheet_id: score.sheet_id, version: Abilitysheet::Application.config.iidx_version)
        user.scores.create(sheet_id: score.sheet_id, state: score.state, version: Abilitysheet::Application.config.iidx_version)
      end
    end
  end

  # 登録時にemailを不要とする
  def email_required?
    false
  end

  def email_changed?
    false
  end
end
