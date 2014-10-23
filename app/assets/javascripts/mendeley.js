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

        function pollProgress() {
            name = $('#mendeley-save-progress').data('name');
            jQuery.get('/progress/' + name, '', function(data) {
                if (data) {
                    percent = 100*(data['current']-data['start'])/(data['end']-data['start']);
                    $('#mendeley-save-progress .bar').width(percent + '%');
                    if (percent >= 100.0) {
                        parent.$('#mendeley-modal').modal('hide');
                    }
                }
                window.setTimeout(pollProgress, 500);
            }, 'json');
        }

        $('#mendeley-save-form').on('ajax:send', function () {
            pollProgress();
            $('#mendeley-save-submit').hide();
            $('#mendeley-save-progress').show();
            return true;
        });
    });

    
})(jQuery);
