(function ($) {
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
