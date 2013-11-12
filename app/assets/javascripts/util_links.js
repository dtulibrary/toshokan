(function ($) {
    $(function() {
        if ($('#util-links').is(":visible")) {
            offset = $('#util-links').offset();
            offset.top += 30;
            offset.left = offset.left - 135;

            $('#login-popover').show();        
            $('#login-popover').offset(offset);
        }
    });

    $(function() {
      $('#dlib-modal').modal();
    });
    
})(jQuery);
