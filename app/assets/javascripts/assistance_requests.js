(function ($) {
  $(function () {
    function updateForm() {
      $('#assistance_request_book_suggest').each(function () {
        var $checkbox = $(this);

        if ($checkbox.is(':checked')) {
          $('.notes-section .required-label').show();
          $('.notes-section').find('label, textarea').addClass('required');
          $('.notes-section textarea').attr('required', 'required');

          $('.automatic-cancellation-section input').attr('disabled', 'disabled');
        } else {
          $('.notes-section .required-label').hide();
          $('.notes-section').find('label, textarea').removeClass('required error');
          $('.notes-section textarea').removeAttr('required');

          $('.automatic-cancellation-section input').removeAttr('disabled');
        }
      });
    }

    $('#assistance_request_book_suggest').change(function () {
      updateForm();
    });

    // Update status on page load
    updateForm();
  });
})(jQuery);
