(function ($) {
  $(function () {
    $('.save-to-mendeley').click(function () {
      var script = document.createElement('script')
      script.setAttribute('src','https://www.mendeley.com/minified/bookmarklet.js');
      $('body').append(script);
      return false;
    });
  });
})(jQuery);
