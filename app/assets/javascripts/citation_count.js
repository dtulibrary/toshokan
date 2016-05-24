(function ($) {

    var CitationCount = function(data){
        var count = function(data, provider, pretty_provider) {
            if (data[provider] == undefined) return;
            this.count = data[provider]['count'];
            this.url = data[provider]['url'];
            this.appendCitationCountToElement = function(element) {
              if (!this.hasUrl() && !this.hasCount())
                return;

              element.append(this.citationCountHTML());
            };
            this.hasUrl = function() {
              return this.url !== undefined && this.url !== null && this.url !== "";
            };
            this.hasCount = function() {
              return this.count !== undefined && this.count !== null && this.count !== "";
            };
            this.citationCountHTML = function() {
              return "<div>" + this.wrapInLink(this.text()) + "</div>"
            };
            this.text = function() {
              return "Citation count " + pretty_provider + ": " + this.count;
            };
            this.wrapInLink = function(toBeWrapped) {
              if (this.hasUrl()) {
                return "<a href='" + this.url + "'>" + toBeWrapped + "</a>";
              } else {
                return toBeWrapped;
              }
            };
        };
        this.elsevier = new count(data, 'elsevier', 'Elsevier');
        this.wok = new count(data, 'web_of_science', 'Web of Science');
        this.appendCitationCountToElement = function(element) {
          this.elsevier.appendCitationCountToElement(element);
          this.wok.appendCitationCountToElement(element);
        };
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
            $citationCountElement.empty();

            var citeCount = new CitationCount(data);
            citeCount.appendCitationCountToElement($citationCountElement);
        },
        function(jqXHR, textStatus, errorThrown) {
            if (window.console !== undefined) {
                console.error("Could not connect to citation count service: " + textStatus);
            }
        });
    });
})(jQuery);
