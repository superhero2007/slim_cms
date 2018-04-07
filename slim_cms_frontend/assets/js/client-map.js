$(document).ready(function() {
    if ($('#data-vector-map').length > 0) {
        clientMap();
    }
});

function clientMap() {

    /***** Map Types *****/
    //Get the map providers
    var providers = {};
    var iconPath = '/themes/angle/vendor/leaflet/plugins/leaflet.iconlayers/examples/';

    providers['Esri_OceanBasemap'] = {
        title: 'Ocean',
        icon: iconPath + 'icons/esri_oceanbasemap.png',
        layer: L.tileLayer('http://server.arcgisonline.com/ArcGIS/rest/services/Ocean_Basemap/MapServer/tile/{z}/{y}/{x}', {
            attribution: 'Tiles &copy; Esri &mdash; Sources: GEBCO, NOAA, CHS, OSU, UNH, CSUMB, National Geographic, DeLorme, NAVTEQ, and Esri',
            maxZoom: 13
        })
    };

    providers['OpenStreetMap_DE'] = {
        title: 'Street',
        icon: iconPath + 'icons/openstreetmap_de.png',
        layer: L.tileLayer('http://{s}.tile.openstreetmap.de/tiles/osmde/{z}/{x}/{y}.png', {
            maxZoom: 18,
            attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
        })
    }

    providers['CartoDB_Positron'] = {
        title: 'Light',
        icon: iconPath + 'icons/cartodb_positron.png',
        layer: L.tileLayer('http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png', {
            attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> &copy; <a href="http://cartodb.com/attributions">CartoDB</a>',
            subdomains: 'abcd',
            maxZoom: 19
        })
    };

    providers['CartoDB_DarkMatter'] = {
        title: 'Dark',
        icon: iconPath + 'icons/cartodb_dark_matter.png',
        layer: L.tileLayer('http://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png', {
            attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> &copy; <a href="http://cartodb.com/attributions">CartoDB</a>',
            subdomains: 'abcd',
            maxZoom: 19
        })
    };

    providers['Stamen_Toner'] = {
        title: 'Contrast',
        icon: iconPath + 'icons/stamen_toner.png',
        layer: L.tileLayer('http://stamen-tiles-{s}.a.ssl.fastly.net/toner/{z}/{x}/{y}.png', {
            attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
            subdomains: 'abcd',
            minZoom: 0,
            maxZoom: 20,
            ext: 'png'
        })
    };

    /***** Map Settings *****/
    //Get the map data and settings
    var data = $('#data-vector-map').data('map-markers');
    var mapSettings = $('#data-vector-map').data('map-settings');
    var clientData = data.clients;

    var mapCenterLat = (typeof mapSettings[0].mapCenterLat === 'undefined') ? 0 : mapSettings[0].mapCenterLat; //Default center lat
    var mapCenterLng = (typeof mapSettings[0].mapCenterLng === 'undefined') ? 0 : mapSettings[0].mapCenterLng; //Default center lng
    var mapCenter = [mapCenterLat, mapCenterLng]; //Default center
    var mapZoom = (typeof mapSettings[0].mapZoom === 'undefined') ? 2 : mapSettings[0].mapZoom; //Default zoom 2
    var mapMinZoom = (typeof mapSettings[0].mapMinZoom === 'undefined') ? 2 : mapSettings[0].mapMinZoom; //Default min zoom 2
    var mapMaxZoom = (typeof mapSettings[0].mapMaxZoom === 'undefined') ? 17 : mapSettings[0].mapMaxZoom; //Default max zoom 2
    var mapClientUrl = mapSettings[0].clientUrl;
    var mapUrlTarget = mapSettings[0].urlTarget;

    //Get Clients
    var clients = L.geoJson(clientData, {

        onEachFeature: function(feature, layer) {
            layer.bindPopup(
                '<div class="leaflet-marker-label">' +
                '<p class="label-name client">' + feature.properties.name + '</p>' +
                '<p class="label-content client">' + feature.properties.address + '</p>' +
                '<p class="label-content client">' +
                '<a href="' + mapClientUrl + feature.properties.client_id + '" target="' + mapUrlTarget + '">More information</a>' +
                '</p>' +
                '</div>'
            );
        }
    });

    //Get GDACS Disasters 
    var disasterData = data.disasters;
    //console.log(disasterData);
    var disasters = L.geoJson(disasterData, {
        pointToLayer: function(feature, latlng) {
            return L.circleMarker(latlng, feature.properties.style);
        },

        onEachFeature: function(feature, layer) {
            layer.bindPopup(
                '<div class="leaflet-marker-label">' +
                '<p class="label-name disasters">' + feature.properties.name + '</p>' +
                '<p class="label-content disasters">' + feature.properties.description + '</p>' +
                '<p class="label-content disasters"><a href="' + feature.properties.link + '" target="_blank">More information</a></p>' +
                '</div>'
            );
        }
    });

    //Create the map with default settings
    var map = L.map('data-vector-map', {
        fullscreenControl: true,
        fullscreenControlOptions: {
            position: 'topleft'
        },
        center: mapCenter,
        zoom: mapZoom,
        minZoom: mapMinZoom,
        maxZoom: mapMaxZoom
    });

    lc = L.control.locate({
        follow: true,
        strings: {
            title: "Show me where I am"
        }
    }).addTo(map);

    var clientsCluster = L.markerClusterGroup();
    clientsCluster.addLayer(clients);

    var layers = [];
    for (var providerId in providers) {
        layers.push(providers[providerId]);
    }

    //Get the overlay (layers)
    var overlayLayers = {
        "Suppliers": clientsCluster
    };

    //control layers (controls the overlay layers)
    var controlLayers = {
        "Disasters": disasters
    }

    //Now add data layers to the map
    //***** Basemap Layers *****
    var ctrl = L.control.iconLayers(layers).addTo(map);

    //Australian Earthquake Risk
    var ausEarthQuakeRisk;

    $.getJSON("/js/aus-earthquake-risk.geojson", function(json) {
        ausEarthQuakeRisk = json;
        //console.log(ausEarthQuakeRisk);
        var geoLayerData = L.geoJson(ausEarthQuakeRisk, {

            onEachFeature: function(feature, layer) {
                var popupContent = getFeaturePopupTable(feature);
                layer.bindPopup(popupContent);
            },
            style: style
        });

        controlLayers['Earthquake Risk'] = geoLayerData;

        //When finish add the layers and controls to the maps
        addOverlayLayersToMap(overlayLayers, map);
        addControlLayersToMap(controlLayers, map);
    });

    //Create the legend
    var legend = L.control({ position: 'bottomright' });

    legend.onAdd = function(map) {

        var div = L.DomUtil.create('div', 'info legend legend-generic'),
            grades = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90],
            labels = ['Lowest', '', '', '', '', '', '', '', '', '', 'Highest'];

        // loop through our density intervals and generate a label with a colored square for each interval
        div.innerHTML += '<p class="legend-title">Scale</p>';
        //Labels First

        div.innerHTML += '<div style="width:100%;">';
        div.innerHTML += '<span style="float:left;">Lowest</span>';
        div.innerHTML += '<span style="float:right;">Highest</span>';
        div.innerHTML += "</div><br />";

        //Now the colours
        for (var i = 0; i < grades.length; i++) {
            div.innerHTML +=
                '<i style="background:' + getColor(grades[i] + 1) + '"></i>';
        }

        return div;
    };

    //Create the legend
    var legend2 = L.control({ position: 'bottomright' });
    legend2.onAdd = function(map) {
        var div = L.DomUtil.create('div', 'info legend');
        div.innerHTML += '<p class="legend-title">Disaster Alert Level</p>';
        div.innerHTML += '<i style="background-color: green"></i>Low<br />';
        div.innerHTML += '<i style="background-color: orange"></i>Medium<br />';
        div.innerHTML += '<i style="background-color: red"></i>High<br />';
        return div;
    };

    legend.addTo(map);
    legend2.addTo(map);

    return;
}

//Adds the overlays and the controls for the overlays to the map
function addOverlayLayersToMap(overlayLayers, map) {

    //***** Overlay Layers ***** 
    for (var prop in overlayLayers) {
        map.addLayer(overlayLayers[prop]);
    }

    return;
}

//Adds the overlays and the controls for the overlays to the map
function addControlLayersToMap(controlLayers, map) {

    //***** Control Layers *****
    L.control.layers(null, controlLayers).addTo(map);

    return;
}

//Get the color for the geojson that has been added to the map
//expects a whole number between 0 and 100 (percentage)
function getColor(d) {
    return d > 90 ? '#800026' :
        d > 80 ? '#bd0026' :
        d > 70 ? '#e31a1c' :
        d > 60 ? '#fc4e2a' :
        d > 50 ? '#fd8d3c' :
        d > 40 ? '#feb24c' :
        d > 30 ? '#fed976' :
        d > 20 ? '#ffeda0' :
        d > 10 ? '#ffffcc' :
        '#ffffff';
}

function style(feature) {
    return {
        fillColor: getColor(
            riskval2percent(feature.properties.RISKVAL)
        ),
        weight: 1,
        opacity: 1,
        color: 'white',
        dashArray: '3',
        fillOpacity: 0.6
    };
}

function riskval2percent(riskval) {
    return riskval === '> 0.10' ? 75 :
        riskval === '0.05 - 0.10' ? 50 :
        25;

}

function getFeaturePopupTable(feature) {
    html = '';

    html += '<table class="table table-striped table-bordered">';
    html += '<tr><th>Attribute</th><th>Value</th></tr>';
    for (var key in feature.properties) {
        if (feature.properties.hasOwnProperty(key)) {
            html += '<tr><td>' + key + '</td><td>' + feature.properties[key] + '</td></tr>';
        }
    }
    html += '</table>';

    return html;
}