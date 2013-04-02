(function ($) {
  $(function() {

    // Load and show cover images if available
    $('.cover-image').each(function () {
      var coverImage = this;
      var imageUrl = $(coverImage).attr('data-href');
      $.ajax(imageUrl, {
        success: function () {
          $(coverImage).removeClass('hidden').css('background-image', 'url(' + imageUrl + ')');
        }
      });
    });

  });
})(jQuery);
