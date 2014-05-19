
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

// add trim function to IE8
if(typeof String.prototype.trim !== 'function') {
  String.prototype.trim = function() {
    return this.replace(/^\s+|\s+$/g, '');
  }
}