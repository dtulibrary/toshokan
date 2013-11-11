//= require 'toshokan'
toshokan.nal = (function () {
  var map;
  var markers = [];

  function removeMarkers() {
    $.each(markers, function () {
      this.setMap(null);
    });
    markers = [];
  }

  return {
    setMap : function (newMap) {
      map = newMap;
    },

    showMap : function () {
      $('#nal-map').show();
    },

    hideMap : function () {
      $('#nal-map').hide();
    },

    updateMap : function () {
      removeMarkers();

      var center = {
        lat  : 55.964576,
        long : 11.351166
      };
      var zoom = 6;
      
      $('#nal-locations .nal-location').each(function () {
        var url = $(this).attr('data-url');

        $(this).find('input:checkbox:checked').each(function () {
          var id = this.name; 
          var library = toshokan.libraries[id];

          $.each(library.branches, function () {
            var branch = this;
            var markerOptions = {
              map : map,
              position : new google.maps.LatLng(branch.googleMapsInfo.lat, branch.googleMapsInfo.long),
              title : library.displayName.en + ' - ' + branch.displayName.en
            };
            var marker = new google.maps.Marker(markerOptions);
            var infoWindowContent = [];
            var infoWindowLinks = [];

            infoWindowContent.push('<h4>' + library.displayName.en + '</h4>');
            infoWindowContent.push('<h5>' + branch.displayName.en + '</h5>');

            if (branch.openingHoursInfo) {
              infoWindowLinks.push('<a target="_blank" href="' + branch.openingHoursInfo.url + '">Opening hours</a>');
            }
            infoWindowLinks.push('<a target="_blank" href="http://www.rejseplanen.dk/bin/query.exe/mn?ZADR=1&Z=' +
              encodeURIComponent(branch.travelPlanInfo.street + ', ' + branch.travelPlanInfo.city) + 
              '">Travel directions</a>'); 
            infoWindowLinks.push('<a target="_blank" href="' + url + '">Online catalog</a>');

            infoWindowContent.push(infoWindowLinks.join(' | '));

            if (branch.displayAddress) {
              infoWindowContent.push('<p>' + branch.displayAddress.address1 + '<br>' + 
                (branch.displayAddress.address2 ? branch.displayAddress.address2 + '<br>' : '') + 
                branch.displayAddress.zip + ' ' + branch.displayAddress.city + '</p>');
            }

            var infoWindow = new google.maps.InfoWindow({
              content: '<div>' + infoWindowContent.join('\n') + '</div>'
            });

            markers.push(marker);
            google.maps.event.addListener(marker, 'click', function () {
              map.panTo(new google.maps.LatLng(branch.googleMapsInfo.lat, branch.googleMapsInfo.long));
              infoWindow.open(map, marker);
            });
          });
        });
      }); 

      map.setCenter(new google.maps.LatLng(center.lat, center.long));
      map.setZoom(zoom);
      google.maps.event.trigger(map, 'resize');
    }
  };
})();

(function ($) {
  $(function () {
    // Initialize NAL map if available
    $('#nal-map').each(function () {
      var map = new google.maps.Map(this, {
        zoom : 6,
        center : new google.maps.LatLng(55.964576,11.351166),
        mapTypeId : google.maps.MapTypeId.ROADMAP
      }); 
      toshokan.nal.setMap(map);
    });

    $('#select-all-nal-locations').click(function () {
      $('#nal-locations input').each(function () {
        this.checked = true;
      });
      toshokan.nal.updateMap();
      return false;
    });

    $('#select-no-nal-locations').click(function () {
      $('#nal-locations input').each(function () {
        this.checked = false;
      });
      toshokan.nal.updateMap();
      return false;
    });
  });
})(jQuery);
