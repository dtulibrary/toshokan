Then(/^Wait for AJAX requests to finish$/) do
  while not page.evaluate_script('jQuery.active').zero? do
    sleep 1
  end
end
