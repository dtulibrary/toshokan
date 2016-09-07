(function ($) {
  var Count = function(data, provider, prefix) {
      if (data[provider] == undefined) return;

      this.provider = provider;
      this.count = data[provider]['count'];
      this.url = data[provider]['url'];
      this.prefix = prefix;

      this.updateCitationCountElement = function() {
        if (!this.hasUrl() && !this.hasCount())
          return;

        this.updateBadgeLink();
        this.showBadge();

        // Change href-attribute of all links which are children of
        // #{provider}_citation_count_wrapper element.
        // Currently (2016-07-22) this is used to turn the Altmetric logo into
        // a link.
        this.updateAllLinksInsideWrapper();
      };

      this.hasUrl = function() {
        return this.url !== undefined && this.url !== null && this.url !== '';
      };

      this.hasCount = function() {
        return this.count !== undefined && this.count !== null && this.count !== '';
      };

      this.updateBadgeLink = function() {
        link = $("#"+this.provider+"_citation_count a");
        if (!this.hasUrl()) {
          link.removeAttr("href");
        } else {
          link.attr("href", this.url);
        }
        link.text(this.prefix + " " + this.count);
      };

      this.showBadge = function() {
        badge = $("#"+this.provider+"_citation_count");
        badge.removeClass("hide");
      };

      this.updateAllLinksInsideWrapper = function() {
        wrapper = $("#"+this.provider+"_citation_count_wrapper");
        if (wrapper.size() != 0) {
          var self = this;

          wrapper.find("a").each(function(i, a) {
            if (!self.hasUrl()) {
              $(a).removeAttr("href");
            } else {
              $(a).attr("href", self.url);
            }
          });

          wrapper.removeClass("hide");
        }
      };
  };
  $(function() {
      var $citationCountElement = $('#citation_count_lookup');
      if ($citationCountElement.size() == 0) return;
      var api = $citationCountElement.data('api');
      var doi = $citationCountElement.data('doi');
      var pmid = $citationCountElement.data('pmid');
      var scopusId = $citationCountElement.data('scopus_id');

      $.ajax(api, {
        data: {
          doi: doi,
          scopus_id: scopusId,
          pmid: pmid
        }}).then(
        function(data, textStatus, jqXHR) {
          var elsevier = new Count(data, 'elsevier', 'Citations: ');
          var wok = new Count(data, 'web_of_science', 'Citations: ');

          elsevier.updateCitationCountElement();
          wok.updateCitationCountElement();
        },
        function(jqXHR, textStatus, errorThrown) {
          if (window.console !== undefined) {
            console.error("Could not connect to citation count service: " + textStatus);
          }
        });

      $.ajax("http://api.altmetric.com/v1/doi/" + doi, {})
        .then(function(data, textStatus, jqXHR) {
          var altmetric = new Count({altmetric:{url: data.details_url, count: Math.round(data.score)}}, 'altmetric', 'Score: ');

          altmetric.updateCitationCountElement();
        },
        function(jqXHR, textStatus, errorThrown) {
          if (window.console !== undefined) {
            console.error("Could not connect to altmetric service: " + textStatus);
          }
        });
    });
})(jQuery);
