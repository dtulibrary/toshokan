// Use typeahead.js and Bloodhound (both defined in typeahead.bundle.js)
// to do auto-completion of query values in the search query form
var completions = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote: {
        url: '/suggest/completion.json?q=%QUERY',
        wildcard: '%QUERY',
    }
});

function transformResponseForDebug(response) {
    console.log(response)
    return response;
};

(function ($) {
    $(function() {
        $('#q').typeahead(null, {
            name: 'completions',
            source: completions
        });
    });
})(jQuery);