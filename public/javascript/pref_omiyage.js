var map;
var geocoder;

function initialize() {
	//位置情報が利用できるか判定
	if ( navigator.geolocation ) {
		navigator.geolocation.getCurrentPosition(function(position){
			//緯度
			var lat = position.coords.latitude;
			//経度
			var lng = position.coords.longitude;
			//緯度,経度をgoogle.maps.LatLngオブジェクトに
			var latlng = new google.maps.LatLng(lat, lng);

			var mapOptions = {
				zoom: 8,
				center: latlng,
				mapTypeId: google.maps.MapTypeId.ROADMAP
			}

			//マップオブジェクトを生成して地図を表示
			map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
			//ジオコーディングを処理するオブジェクト
			geocoder = new google.maps.Geocoder();

			//無名関数の第1引数: ジオコーディングした結果 第2引数: ジオコーディングの成否
			geocoder.geocode({'latLng': latlng}, function(results, status){
				if ( status == google.maps.GeocoderStatus.OK ) {
					//逆ジオコーディングの結果が存在するか
					if ( results[0] ) {
						//県名を取得
						$.each(results[0].address_components, function(index, value){
							if ( value.types[0] == 'administrative_area_level_1' ) {
								console.log(value.long_name);

								var marker = new google.maps.Marker({
									position: latlng,
									map: map
								});

								var infowindow = new google.maps.InfoWindow();
								infowindow.setContent(value.long_name);
								infowindow.open(map, marker);

								//おみやげ情報の取得
								//all
								$.ajax({
									url: '/items/search/' + value.long_name + '?genre_id=551167',
									settings: {
										type: 'GET',
										ataType: 'html'
									}
								}).done(function(data){
									console.log('success');
									console.log(data);

									//document.getElementById('rakutem-items').innerHTML(data);
									$('#ranking').html(data);
									$('#locate').val(value.long_name);
									window.location.hash = 'first';
								}).fail(function(data){
									console.log('fail');
								});
							}
						});

					} else {
						//指定された座標の逆ジオコーディングが存在しない場合
						console.log('Not found geolocation');
					}
				} else {
					//ジオコーディング失敗
					console.log('Geolocation faild');
				}
			});
		});
	} else {
		//HTML5　navigator.geolocationが使えない場合
	}
}

//administrative_area_level_1が県
//県名を取得
function getPrefName(result) {
	$.each(result.address_components, function(index, value){
		if ( value.types[0] == 'administrative_area_level_1' ) {
			console.log(value.long_name);
			return value.long_name;
		}
	});
}

//google.maps.event.addDomListener(window, 'load', initialize);
