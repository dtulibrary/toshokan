module ParamsHelper

  # Check if a certain subset of elements in params all have blank values
  def params_blank? names, local_params = params
    local_params.select {|k,v| names.include? k}.all? {|k,v| v.blank?}
  end

  # Return all elements of params from within a certain subset that have non-blank values
  def params_with_values names, local_params = params
    local_params.select {|k,v| names.include?(k) && !v.blank?}
  end
end
