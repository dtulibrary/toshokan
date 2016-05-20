(function ($) {

    var CitationCount = function(data){
        var count = function(data, provider) {
            if (data[provider] == undefined) return;
            this.count = data[provider]['count'];
            this.url = data[provider]['url'];
            this.text = "<div><a href='" + this.url + "'> Citation count " + provider + ": " + this.count + "</a></div>";
        };
        this.elsevier = new count(data, 'elsevier');
        this.wok = new count(data, 'wok');
    };
  $(function() {
      var $citationCountElement = $('#citation_count_lookup');
      if (!$citationCountElement) return;
      var api = $citationCountElement.data('api');
      var doi = $citationCountElement.data('doi');
      var pmid = $citationCountElement.data('pmid');
      var scopus_id = $citationCountElement.data('scopus_id');
      $.ajax(api, {
          data: {
              doi: doi,
              scopus_id: scopus_id,
              pmid: pmid
          }}).then(
        function(data, textStatus, jqXHR) {
            var citeCount = new CitationCount(data);
            var text = "";
            if (!$.isEmptyObject(citeCount.elsevier)) text += citeCount.elsevier.text;
            if (!$.isEmptyObject(citeCount.wok)) text += citeCount.wok.text;
            $citationCountElement.empty().html(text);
        },
        function(jqXHR, textStatus, errorThrown) {
            if (window.console !== undefined) {
                console.error("Could not connect to citation count service: " + textStatus);
            }
        });
    });
})(jQuery);
