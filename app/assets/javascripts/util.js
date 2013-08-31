
function addErrorFlashMessage(message) {
  $("#main-flashes > .flash_messages").append(
    '<div class="alert alert-error">' 
    + message +
    '<a class="close" data-dismiss="alert" href="#">&times;</a></div>'
  );
}

function partial(func /*, 0..n args */) {
  var args = Array.prototype.slice.call(arguments, 1);
  return function() {
    var allArguments = args.concat(Array.prototype.slice.call(arguments));
    return func.apply(this, allArguments);
  };
}
