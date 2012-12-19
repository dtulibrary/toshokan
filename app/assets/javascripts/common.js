$(function(){
  // $('.tag_control .dropdown.form a').on('click', function (e) {
  //   var x = setTimeout('$("input").focus()', 500);
  // });

  $('.tag_control .dropdown.form form input,label').on('click', function (e) {
    e.stopPropagation();
  });

});
