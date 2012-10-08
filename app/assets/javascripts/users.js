(function ($) {

  // Switch user functionality
  $(function () {
    var data = [];
    var form = $('#switch_user_form.ajax');

    /* Pull switch user form out into body to avoid other 
     * elements with position: absolute to interfere with positioning.
     */
    form.remove();
    $('body').append(form);

    $('#switch_user').click(function () {
      var center = {
        x : $(window).width() / 2,
        y : $(window).height() / 2
      };

      // Position dialog
      form.css({
        top : '4em',
        left : (center.x - form.width() / 2) + 'px'
      });

      // Display dialog
      $('#overlay').toggle();
      form.toggle();

      if (form.is(':visible')) {
        $('#user_identifier').focus();
      }

      return false;
    });

    $('#switch_user_form .cancel').click(function () {
      $('#overlay').toggle();
      form.toggle();

      return false;
    });

    $('#switch_user_form').submit(function () {
      var identifier = $('#user_identifier').val();

      $.ajax({
        url : 'user/session',
        type : 'put',
        data : 'ajax=true&user[identifier]=' + identifier,
        statusCode : {
          404 : function (response, statusText, statusCode) {
            $('#switch_user_form form').replaceWith(response.responseText);
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
