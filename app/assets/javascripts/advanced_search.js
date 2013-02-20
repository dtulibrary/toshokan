(function ($) {

  $(function () {
    
    $('.advanced-search').each(function () {
      // Disable simple search
      $('#searchbar').find('input, button, select').attr('disabled', 'disabled');
    });

  });
})(jQuery);
