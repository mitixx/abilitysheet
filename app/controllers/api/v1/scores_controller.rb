class Api::V1::ScoresController < Api::V1::BaseController
  def sync_iidxme
    user = User.find_by!(iidxid: params[:iidxid])
    IidxmeWorker.perform_async(user.id)
    render json: { result: :ok, date: Date.today }
  end
end