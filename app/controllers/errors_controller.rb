class ErrorsController < ActionController::Base
  def access_denied
    render(status: 401)
  end

  def not_found
    render(status: 404)
  end

  def change_rejected
    render(status: 422)
  end

  def internal_server_error
    render(status: 500)
  end
end
