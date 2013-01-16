$(function(){
  $('.dropdown.form form input,label').on('click', function (e) {
    e.stopPropagation();
  });
});
