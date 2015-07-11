class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :shift_domain
  before_action :miniprofiler

  def shift_domain
    host = 'iidxas.tk'
    return unless request.url.include?(host)
    path = Rails.root.join('tmp', 'shift_domain')
    num = File.read(path).to_i
    num += 1
    File.write(path, num)
    redirect_to request.url.gsub(host, 'iidx12.tk')
  end

  protected

  def scores_exists?
    return if current_user.scores.present?
    flash[:alert] = '処理を受け付けませんでした．'
    flash[:notice] = 'この状態が続くようであればお問い合わせください'
    render :reload
  end

  def return_404
    render file: Rails.root.join('public', '404.html'), status: 404, layout: true, content_type: 'text/html'
  end

  def check_xhr
    return if request.xhr?
    return_404
  end

  def configure_permitted_parameters
    # strong parametersを設定し、usernameを許可
    devise_parameter_sanitizer.for(:sign_up) << [:username, :iidxid, :djname, :grade, :pref]
    devise_parameter_sanitizer.for(:account_update) << [:username, :djname, :grade, :pref]
  end

  def admin_user!
    return true if current_user.admin?
    flash[:alert] = '許可されていないページです'
    redirect_to root_path
  end

  def special_user!
    return if current_user.special?
    flash[:alert] = '不正な操作です．'
    redirect_to list_logs_path
  end

  def owner_user!
    return if current_user.owner?
    flash[:alert] = '許可されていないページです'
    redirect_to root_path
  end

  def member_user!
    return if current_user.member?
    flash[:alert] = '許可されていないページです'
    redirect_to root_path
  end

  def miniprofiler
    Rack::MiniProfiler.authorize_request if user_signed_in? && current_user.admin?
  end
end
