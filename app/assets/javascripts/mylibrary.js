(function ($) {
  $(function() {

    if($('.mylibrary').length) {

      $('.delete').each ( function() {
        $(this).bind('ajax:success', function(evt, data, status, xhr) {
          $(this).closest('.item').fadeOut();
        });
      });

      $('.action > a:not(.delete)').each ( function() {
        $(this).bind('ajax:success', function(evt, data, status, xhr) {
          $(this).addClass('hidden');
          $(this).siblings().removeClass('hidden');
        });
      });

      $('.action > a').each ( function() {
        $(this).bind('ajax:error', function(evt, xhr, status, error){ 
          addErrorFlashMessage(xhr.responseText);
        });
      });

    }
  });
})(jQuery);
