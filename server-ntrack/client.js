var ntap = {
	map : null,
	deviceMarkers : {},
	devices : [],
	socket : null,

	init : function() {
		ntap.initMaps();
		ntap.initSocket();
		ntap.bindUiEvents();
	},

	initMaps : function() {
		var mapOptions = {
			zoom : 10,
			center : new google.maps.LatLng(40.99291067804179, 29.024468994140655),
			mapTypeId : google.maps.MapTypeId.SATELLITE
		};
		ntap.map = new google.maps.Map(document.getElementById('map-canvas'),mapOptions);
	},
	
	initSocket : function() {
		ntap.socket = io.connect('http://localhost:1188');

		ntap.socket.on('alive', function(data) {
			console.log('alive: ' + JSON.stringify(data));
			ntap.addOrUpdateDeviceMarker(data);
		});

		ntap.socket.on('connected', function(data) {
			console.log('connected: ' + JSON.stringify(data));
		});
	},

	bindUiEvents : function() {
		$('#device-list').on('click', 'p', function() {
			ntap.deviceSelected($(this));
		});

		$('#device-list span').click(function() {
			ntap.toggleDeviceList();
		});
	},

	addOrUpdateDeviceMarker : function(data) {
		var currentMarker = ntap.deviceMarkers[data.device];
		if (!currentMarker) {
			var color = (0x1000000+(Math.random())*0xffffff).toString(16).substr(1,6);
			
		    currentMarker = new google.maps.Marker({
				icon : new google.maps.MarkerImage('https://chart.googleapis.com/chart?chst=d_map_pin_icon&chld=mobile|'+color),
				labelContent : data.device,
				labelAnchor : new google.maps.Point(22, 0),
				labelClass : "marker-label",
				labelStyle : {
					opacity : 0.75
				}
			});
			currentMarker.setMap(ntap.map);
		}
		var point = new google.maps.LatLng(data.lat, data.long);
		currentMarker.setPosition(point);
		ntap.deviceMarkers[data.device] = currentMarker;
		ntap.adjustDeviceList(data.device);
	},

	adjustDeviceList : function(device) {
		if (ntap.devices.indexOf(device) < 0) {
			ntap.devices.push(device);
			var html = '<p data-device="' + device + '">' + device + '</p>';
			$('#device-list').append(html);
		}
		$('#device-list span').text('Devices (' + ntap.devices.length + ')');
	},

	deviceSelected : function($p) {
		for ( var key in ntap.deviceMarkers) {
			ntap.deviceMarkers[key].setVisible(false);
		}
		var device = $p.data('device');
		ntap.deviceMarkers[device].setVisible(true);
		$('#device-list p').removeClass('selected');
		$p.addClass('selected');
		var position =ntap.deviceMarkers[device].position;
		ntap.map.panTo(position);
	},

	toggleDeviceList : function() {
		$('#device-list p').slideToggle(100);
	},

	_endobj : null
}

$(document).ready(function() {
	ntap.init();
});
