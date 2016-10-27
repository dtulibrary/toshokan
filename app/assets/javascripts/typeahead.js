
/*global Bloodhound */
$(document).ready(function() {

    'use strict';
    $('#grouped_suggestions[data-autocomplete-enabled="true"]').each(function() {
        var $el = $(this);
        var suggestUrl = $el.data().autocompletePath;

        var allterms = new Bloodhound({
            datumTokenizer: Bloodhound.tokenizers.obj.whitespace("term"),
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            sufficient: 1,
            remote: {
                url: suggestUrl + '?q=%QUERY&dictionary=keywords_lookup',
                wildcard: '%QUERY'
            }
        });
        var journaltitles = new Bloodhound({
            datumTokenizer: Bloodhound.tokenizers.obj.whitespace("term"),
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            sufficient: 1,
            remote: {
                url: suggestUrl + '?q=%QUERY&dictionary=journal_lookup',
                wildcard: '%QUERY'
            }
        });
        var authors = new Bloodhound({
            datumTokenizer: Bloodhound.tokenizers.obj.whitespace("term"),
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            sufficient: 1,
            remote: {
                url: suggestUrl + '?q=%QUERY&dictionary=author_lookup',
                wildcard: '%QUERY'
            }
        });

    //('term')/terms.initialize();
    allterms.initialize();

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
            source: allterms,
            templates: {
                header: '<h3>Subjects</h3>'
            }
        },
        {
            name: 'terms',
            displayKey: 'term',
            source: journaltitles,
            templates: {
                header: '<h3>Journal Titles</h3>'
            }
        },
        {
            name: 'terms',
            displayKey: 'term',
            source: authors,
            templates: {
                header: '<h3>Authors</h3>'
            }
        });
    });
    $('#mixed_suggestions[data-autocomplete-enabled="true"]').each(function() {
        var $el = $(this);
        var suggestUrl = $el.data().autocompletePath;

        var allterms = new Bloodhound({
            datumTokenizer: Bloodhound.tokenizers.obj.whitespace("term"),
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            sufficient: 1,
            remote: {
                url: suggestUrl + '?q=%QUERY&dictionary=allterms_lookup',
                wildcard: '%QUERY'
            }
        });

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
            source: allterms
        });
    });
});

