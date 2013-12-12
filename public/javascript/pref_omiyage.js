var map;
var geocoder;

function initialize() {
	//位置情報が利用できるか判定
	if ( navigator.geolocation ) {
		navigator.geolocation.getCurrentPosition(
			loadCurrentPosition,
			loadTemporaryPosition,
			{timeout:6000}
		);
	} else {
		loadTemporaryPosition();
	}
}

function loadCurrentPosition(position) {
	//緯度
	var lat = position.coords.latitude;
	//経度
	var lng = position.coords.longitude;
	//緯度,経度をgoogle.maps.LatLngオブジェクトに
	var latlng = new google.maps.LatLng(lat, lng);
	reloadMap(latlng);
}

function loadTemporaryPosition() {
	//HTML5　navigator.geolocationが使えない場合
	$('#error_dialog').foundation('reveal', 'open');
	//東京駅の座標をセット
	lat = 35.681382;
	lng = 139.766084;
	var latlng = new google.maps.LatLng(lat, lng);
	reloadMap(latlng);
}

function reloadMap(latlng) {
	var mapOptions = {
		zoom: 9,
		center: latlng,
		mapTypeId: google.maps.MapTypeId.ROADMAP
	}
	$('#ranking').html('');
	$('#floatingBarsG').show();

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
				var locality = '';
				$.each(results[0].address_components, function(index, value){
					if (value.types[0] == 'locality' ) {
						if (value.long_name.indexOf('郡') < 0) {
							locality = value.long_name;
						}
					}
					if ( value.types[0] == 'administrative_area_level_1' ) {
						console.log(value.long_name);

						var marker = new google.maps.Marker({
							position: latlng,
							map: map
						});

						var infowindow = new google.maps.InfoWindow();
						if (locality != '') {
							infowindow.setContent(value.long_name + '　' +locality);
						} else {
							infowindow.setContent(value.long_name);
						}
						infowindow.open(map, marker);
						// マップクリックイベントを追加
						google.maps.event.addListener(map, 'click', function(e)
						{
							// ポジションを変更
							marker.position = e.latLng;
							// マーカーをセット
							marker.setMap(map);
							reloadMap(e.latLng);
						})
						//おみやげ情報の取得
						var locate = ($('#search_mode').val() == 'prefecture') ? value.long_name : locality;
						var genre_id = $('.category_id').val();
						$.ajax({
							url: '/items/search/' + locate + '?genre_id=' + genre_id,
							settings: {
								type: 'GET',
								ataType: 'html'
							}
						}).done(function(data){
							console.log('success');
							console.log(data);

							$('#ranking').html(data);
							$('#locate').val(locate);
							$("#prefname").text(locate + "のお土産");
							$('#prefecture').val(value.long_name);
							$('#locality').val(locality);
							if ($('#search_mode').val() == 'prefecture') {
								$('#prefecture_search').hide();
								$('#locality_search').show();
							} else {
								$('#prefecture_search').show();
								$('#locality_search').hide();
							}
							$('#floatingBarsG').hide();
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
