(function ($) {

  $(function () {
    var moreOptions = $('#more_options');
    var mainContainer = $('#main-container');
    var searchForm = $('.search-query-form');
    var moreOptionsToggle = $('#more_options_toggle');

    // TODO: Make "more options" submit form when pressing ENTER

    // Remove "more options" from search form so it can be styled correctly with z-index
    $('body').append(moreOptions.detach());

    (function () {
      var hidden = true;

      moreOptionsToggle.click(function () {
        var headerHeight = $('#header-navbar-fixed-top').height();
        if (hidden) {
          // Position "more options" form - don't know how to do it in CSS since it's an absolutely positioned element
          // This breaks the responsive design when actively transitioning to another css media query (ie by resizing window).
          moreOptions.css('top', headerHeight).removeClass('hide');
          moreOptions.css('left', mainContainer.offset().left + 'px');
        } else {
          moreOptions.css('top', '-100%').addClass('hide');
        }
        hidden = !hidden;
        return false;
      });

    })();

    searchForm.submit(function () {
      moreOptions.hide();

      // Remove hidden fields from search form that match the ones from the "more options" form
      moreOptions.find('.span9 input').each(function () {
        searchForm.find('input[name="' + this.name + '"]').remove();
      });
      searchForm.find('input[name="match_mode"]').remove();

      // Put the "more options" back into the search form for submission
      searchForm.append(moreOptions.detach());
    });
  });

})(jQuery);
