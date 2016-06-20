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
    var refinedPageInput = $('#refined_page_input');
    var refinedPublisherInput = $('#refined_publisher_input');
    var refinedYearInput = $('#refined_year_input');
    var refinedAuthorInput = $('#refined_author_input');

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

      var setRefinedPage = function(newPage) {
        refinedPageInput.val(newPage);
      };

      var setRefinedPublisher = function(newPublisher) {
        refinedPublisherInput.val(newPublisher);
      };

      var setRefinedYear = function(newYear) {
        refinedYearInput.val(newYear);
      };

      var setRefinedAuthor = function(newAuthor) {
        refinedAuthorInput.val(newAuthor);
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
            setRefinedAuthor(data.author);
            setRefinedTitle(data.title);
            setRefinedJournalTitle(data.journal_title);
            setRefinedVolume(data.volume);
            setRefinedPage(data.page);
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
        if (refinedAuthorInput.val())
          params.push('author:"' + refinedAuthorInput.val() + '"');
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
        if (refinedPageInput.val())
          params.push('page:"' + refinedPageInput.val() + '"');

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

