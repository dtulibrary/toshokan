(function ($) {
  $(function() {
    $('div[data-citation-count]').each(function (index, citationCountElement) {
      var citationCountElement = $(citationCountElement);
      var doi = citationCountElement.attr('data-doi');
      // TODO TLNI: Get citation count (fix URL)
      $.ajax("http://localhost:3003/citation_count/", {
        data: {"doi": doi}
      }).then(
        function(data, textStatus, jqXHR) {
          var get_scopus_citation_count_from_data = function(data) {
            if (data === undefined || data === null)
              return "0";

            var data_elsevier = data['elsevier'];

            if (data_elsevier === undefined || data_elsevier === null)
              return "0";

            var data_elsevier_count = data_elsevier['count'];

            if (data_elsevier_count === undefined || data_elsevier_count === null || data_elsevier_count === "")
              return "0";

            return data_elsevier_count;
          };

          var get_web_of_science_citation_count_from_data = function(data) {
            if (data === undefined || data === null)
              return "0";

            var data_web_of_science = data['web_of_science'];

            if (data_web_of_science === undefined || data_web_of_science === null)
              return "0";

            var data_web_of_science_count = data_web_of_science['count'];

            if (data_web_of_science_count === undefined || data_web_of_science_count === null || data_web_of_science_count === "")
              return "0";

            return data_web_of_science_count;
          };

          var scopus_citation_count = get_scopus_citation_count_from_data(data);
          var web_of_science_citation_count = get_web_of_science_citation_count_from_data(data);

          citationCountElement.empty().html("<div>Scopus citation count: "+scopus_citation_count+"</div><div>ISI citation count: "+web_of_science_citation_count+"</div>");
        },
        function(jqXHR, textStatus, errorThrown) {
          // TODO TLNI: Do something on error?
        });
    });

  });
})(jQuery);
