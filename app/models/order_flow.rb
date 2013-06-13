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
        :rd => [:email, :mobile],
        :dtu => [:email, :mobile]
      },
      :dtu_student => {
        :rd => [:email, :mobile, :terms_accepted],
        :dtu => [:email, :mobile]
      },
      :public => {
        :rd => [:email, :mobile, :terms_accepted, :customer_ref],
        :dtu => [:email, :mobile, :terms_accepted, :customer_ref]
      }
    }
  end
  
  def self.order_steps_matrix
    {
      :dtu_staff => {
        :rd => [:delivery_info, :confirm, :done],
        :dtu => [:delivery_info, :confirm, :done]
      },
      :dtu_student => {
        :rd => [:delivery_info, :confirm, :payment, :done],
        :dtu => [:delivery_info, :confirm, :done]
      },
      :public => {
        :rd => [:delivery_info, :confirm, :payment, :done],
        :dtu => [:delivery_info, :confirm, :payment, :done]
      }
    }
  end


end
