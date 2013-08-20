
function addErrorFlashMessage(message) {
  $("#main-flashes > .flash_messages").append(
    '<div class="alert alert-error">' 
    + message +
    '<a class="close" data-dismiss="alert" href="#">&times;</a></div>'
  );
}
