(function ($) {
    // Launch Mendeley Web Importer
    $(function () {
        $('body').on('click', '.save-to-mendeley', function () {
            var script = document.createElement('script')
            script.setAttribute('src','https://www.mendeley.com/minified/bookmarklet.js');
            $('body').append(script);
            return false;
        });
    });
    
    // Use Mendeley API
    $(function () {
        $('body').on('click', '.save-to-mendeley-api', function () {
            $('#mendeley-modal').modal('show');
            params = $(this).data('document') ? '/' + $(this).data('document') : location.search
            $('#mendeley-modal #mendeley-iframe').attr('src', location.origin + '/mendeley' + params);
            return false;
        });
    });
})(jQuery);
