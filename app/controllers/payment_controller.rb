class PaymentController < ApplicationController
  
  def credit_card
    callback_url = params[:callback_url]
    accept_url = params[:accept_url]
    cancel_url = params[:cancel_url]

    if accept_url && cancel_url
      redirect_to accept_url
    else
      render :text => 'Missing parameters', :status => :bad_request, :layout => nil
    end
  end

end
