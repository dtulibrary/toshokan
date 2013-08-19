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

      function addErrorFlashMessage(message) {
        $("#main-flashes > .flash_messages").append(
          '<div class="alert alert-error">' 
          + message +
          '<a class="close" data-dismiss="alert" href="#">&times;</a></div>'
        );
      }
    }
  });
})(jQuery);
