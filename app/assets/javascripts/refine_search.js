(function($) {
  $(function() {
    var refineSearchQueryElement = $('#refine_search_query');
    if (!refineSearchQueryElement)
      return;

    var doRefinedSearchButton = $('#do_refined_search');
    if (!doRefinedSearchButton)
      return;

    var showRefineSearchButton = $('#show_refine_search_query');
    if (!showRefineSearchButton)
      return;

    var query = refineSearchQueryElement.data('query');

    var refinedTitleInput = $('#refined_title_input');
    var refinedJournalInput = $('#refined_journal_input');
    var refinedVolumeInput = $('#refined_volume_input');
    var refinedPagesInput = $('#refined_pages_input');
    var refinedPublisherInput = $('#refined_publisher_input');
    var refinedYearInput = $('#refined_year_input');
    var refinedAuthorsInput = $('#refined_authors_input');

    var parseQuery = function(query) {
      var setRefinedTitle = function(newTitle) {
        refinedTitleInput.val(newTitle);
      };

      var setRefinedJournalTitle = function(newJournalTitle) {
        refinedJournalInput.val(newJournalTitle);
      };

      var setRefinedVolume = function(newVolume) {
        refinedVolumeInput.val(newVolume);
      };

      var setRefinedPages = function(newPages) {
        refinedPagesInput.val(newPages);
      };

      var setRefinedPublisher = function(newPublisher) {
        refinedPublisherInput.val(newPublisher);
      };

      var setRefinedYear = function(newYear) {
        refinedYearInput.val(newYear);
      };

      var setRefinedAuthors = function(newAuthors) {
        refinedAuthorsInput.val(newAuthors);
      };

      var queryFreeCite = function() {
        $.ajax(
            "/refine_search/parse_search_query",
            {
              method: "GET",
              data: { q: query },
            }
        ).then(
          function(data, textStatus, jqXHR) {
            setRefinedAuthors(data.authors);
            setRefinedTitle(data.title);
            setRefinedJournalTitle(data.journal_title);
            setRefinedVolume(data.volume);
            setRefinedPages(data.pages);
            setRefinedPublisher(data.publisher);
            setRefinedYear(data.year);
            showRefineSearchButton.show();
          },
          function(jqXHR, textStatus, errorThrown) {
            console.log("parse_search_query request failed.");
          }
        );
      };

      if (query !== null && query !== undefined && query !== "")
        queryFreeCite();
    };

    parseQuery(query);

    doRefinedSearchButton.click(function() {
      var constructUrl = function() {
        var baseUrl = "/en/catalog?q=";

        var params = [];
        if (refinedAuthorsInput.val())
          params.push('authors:"' + refinedAuthorsInput.val() + '"');
        if (refinedTitleInput.val())
          params.push('title:"' + refinedTitleInput.val() + '"');
        if (refinedJournalInput.val())
          params.push('journal_title:"' + refinedJournalInput.val() + '"');
        if (refinedVolumeInput.val())
          params.push('volume:"' + refinedVolumeInput.val() + '"');
        if (refinedPublisherInput.val())
          params.push('publisher:"' + refinedPublisherInput.val() + '"');
        if (refinedYearInput.val())
          params.push('year:"' + refinedYearInput.val() + '"');
        if (refinedPagesInput.val())
          params.push('pages:"' + refinedPagesInput.val() + '"');

        var result = baseUrl + encodeURI(params.join(" "));

        return result;
      };

      $(this).attr("href", constructUrl());
    });

    showRefineSearchButton.click(function() {
      showRefineSearchButton.hide();
      refineSearchQueryElement.show();
    });
  });
})(jQuery);

