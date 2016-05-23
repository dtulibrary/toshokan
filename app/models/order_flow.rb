class OrderFlow
  
  attr_reader :steps, :fields, :current_step_idx

  def initialize user, supplier
    @current_step_idx = 0
    @user_type = :public
    @user_type = :dtu_student if user.student?
    @user_type = :dtu_staff if user.employee?
    @steps = OrderFlow.order_steps_matrix[@user_type][supplier]
    @fields = OrderFlow.delivery_info_fields_matrix[@user_type][supplier]
  end

  def current_step
    @steps[@current_step_idx]
  end

  def current_step= step
    @current_step_idx = steps.index(step) || 0
  end

  def continue
    @current_step_idx += 1 unless complete?
  end

  def back
    @current_step_idx -= 1 unless complete? || @current_step_idx < 0
  end

  def complete?
    not @current_step_idx < steps.size
  end

  def self.delivery_info_fields_matrix
    {
      :dtu_staff => {
        :rd  => [:email],
        :tib => [:email],
        :dtu => [:email]
      },
      :dtu_student => {
        :rd  => [:email, :terms_accepted],
        :tib => [:email, :terms_accepted],
        :dtu => [:email]
      },
      :public => {
        :rd  => [:email, :terms_accepted, :customer_ref, :requirements],
        :tib => [:email, :terms_accepted, :customer_ref, :requirements],
        :dtu => [:email, :terms_accepted, :customer_ref, :requirements]
      }
    }
  end
  
  def self.order_steps_matrix
    {
      :dtu_staff => {
        :rd  => [:delivery_info, :confirm, :done],
        :tib => [:delivery_info, :confirm, :done],
        :dtu => [:delivery_info, :confirm, :done]
      },
      :dtu_student => {
        :rd  => [:delivery_info, :confirm, :payment, :done],
        :tib => [:delivery_info, :confirm, :payment, :done],
        :dtu => [:delivery_info, :confirm, :done]
      },
      :public => {
        :rd  => [:delivery_info, :confirm, :payment, :done],
        :tib => [:delivery_info, :confirm, :payment, :done],
        :dtu => [:delivery_info, :confirm, :payment, :done]
      }
    }
  end


end
