(function ($) {
    $(function() {
        if ($('#util-links').is(":visible")) {
            offset = $('#util-links').offset();
            console.log(offset);
            offset.top += 30;
            offset.left = offset.left - 135;
            console.log(offset);

            $('#login-popover').show();        
            $('#login-popover').offset(offset);
        }
    });
    
})(jQuery);
