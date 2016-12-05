class ErrorsController < ActionController::Base
  def show
    exception  = env['action_dispatch.exception']
    @status = ActionDispatch::ExceptionWrapper.new(env, exception).status_code
    render(status: @status)
  end
end
