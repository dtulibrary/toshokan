// allows form elements inside a bootstrap dropdown recieve input
// without this, the dropdown would close when clicking the form elements
(function($){
  $('.dropdown.form form input,label').on('click', function (e) {
    e.stopPropagation();
  });
})(jQuery);
