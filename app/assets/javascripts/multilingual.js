(function ($) {
  $(function () {

    // Enable switching between different languages
    $('.multilingual .locale-select a').each(function () {
      var locale = $(this).attr('data-locale');
      var container = $(this).closest('.multilingual');

      $(this).click(function () {
        // Display selectors for other languages and hide the one for active language
        container.find('.locale-select a').each(function () {
          if ($(this).attr('data-locale') == locale) {
            $(this).addClass('hidden');
          } else {
            $(this).removeClass('hidden');
          }
        });

        // Display content for selected language and hide content for other languages
        container.find('.localized-content').each(function () {
          $(this).addClass('hidden');
          if ($(this).attr('data-locale') == locale) {
            $(this).removeClass('hidden');
          }
        });

        // Copy form contents if required
        if (container.hasClass('copy-forms')) {
        }
        return false;
      });
    });

  });
})(jQuery);
