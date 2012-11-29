(function ($) {

  // Enable modal display when clicking on "Switch User"
  $(function () {
    $('#switch_user').click(function () {
      $('#switch_user_modal').modal({
        backdrop: false
      });
      return false;
    });
  });

  // Intercept switch user form submission
  $(function () {
    var form = $('#switch_user_modal form');

    form.submit(function () {
      var identifier = form.find('#identifier').val();
      var errors = form.find('.alert.alert-error');

      errors.hide();

      $.ajax({
        url : 'user/session',
        type : 'put',
        data : 'ajax=true&user[identifier]=' + identifier,
        statusCode : {
          404 : function (response, statusText, statusCode) {
            errors.text(response.responseText);
            errors.show();
          }
        },
        success : function () {
          window.location.reload(true);
        },
      });
      return false;
    });
  });

  // User role management
  $(function () {
    $('.save-user').hide();

    $('.update-role.ajax').each(function () {
      var checkbox = this;
      var checked = checkbox.checked;
      var url = $(checkbox).closest('form').attr('action');
      var roleId = $(checkbox).attr('data-role_id');

      if (url) {
        $(this).click(function () {
          $.ajax({
            url : url,
            type : checked ? 'delete' : 'put',
            data : {
              'role' : roleId,
              'ajax' : true
            },
            success : function (data, statusCode, response) {
              checked = !checked;
              checkbox.checked = checked;
            },
            error : function (response, statusCode) {
              alert('There was an error handling your request');
            }
          });

          return false;
        });
      }
    });
  });
})(jQuery);
