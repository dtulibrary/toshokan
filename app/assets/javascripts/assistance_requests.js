(function ($) {
  $(function () {
    function updateNoteFieldStatus() {
      $('#assistance_request_book_suggest').each(function () {
        var $checkbox = $(this);

        if ($checkbox.is(':checked')) {
          $('.notes-section .required-label').show();
          $('.notes-section').find('label, textarea').addClass('required');
          $('.notes-section textarea').attr('required', 'required');
        } else {
          $('.notes-section .required-label').hide();
          $('.notes-section').find('label, textarea').removeClass('required error');
          $('.notes-section textarea').removeAttr('required');
        }
      });
    }

    $('#assistance_request_book_suggest').change(function () {
      updateNoteFieldStatus();
    });

    // Update status on page load
    updateNoteFieldStatus();
  });
})(jQuery);
