
/*global Bloodhound */
$(document).ready(function() {

    'use strict';
    $('[data-autocomplete-enabled="true"]').each(function() {
        var $el = $(this);
        var suggestUrl = $el.data().autocompletePath;

        var terms = new Bloodhound({
            datumTokenizer: Bloodhound.tokenizers.obj.whitespace("term"),
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            sufficient: 1,
            remote: {
                url: suggestUrl + '?q=%QUERY',
                wildcard: '%QUERY'
            }
        });

    //('term')/terms.initialize();
    var promise = terms.initialize();

    promise
    .done(function() {
        console.log('ready to go!'); 
        $el.typeahead({
                hint: false,
                highlight: true,
                minLength: 2,
                async: true,
                limit: 5
            },
            {
                name: 'terms',
                displayKey: 'term',
                source: terms
            });
    });
    });
    $('.typeahead').bind('typeahead:asyncreceive', function(ev, query, name) {
          console.log('Receive: ' + query);
    });
});

