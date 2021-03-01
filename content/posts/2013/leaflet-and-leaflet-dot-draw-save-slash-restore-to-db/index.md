---
layout: post
title: Leaflet and Leaflet.draw save and restore
date: 2013-11-12 06:28:00
tags: [ Leaflet, Leaflet.draw, map, maps, OSM]
---

I work on a project that has a form including a map, so a logged in user can enter his data and drawing features on the map and save it afterwards.
The user gets a page that shows the map with the features on it. I will show how to save and restore the drawn data as geoJSON and how to save circles because that type of feature is not supported by geoJSON.

## drawing the features

This is a basic map with drawing enabled

```html
<!DOCTYPE html>
<html>
    <head>
          <meta charset="utf-8">
          <title>Leaflet example</title>
          <link href='http://cdn.leafletjs.com/leaflet-0.6.4/leaflet.css' rel='stylesheet' type='text/css' title='default' />
          <script type='text/javascript' src='http://cdn.leafletjs.com/leaflet-0.6.4/leaflet.js'></script>
          <link href='css/leaflet.draw.css' rel='stylesheet' type='text/css' title='default' />
          <script type='text/javascript' src='js/leaflet.draw.js'></script>
    </head>
    <body>
        <script>
            $(function() {
                var map = L.map('div#map').setView([47.5, 8.3], 12);

                L.tileLayer('http://{s}.tile.cloudmade.com/de7796f726fb415a87ec97b5e4ee7db3/997/256/{z}/{x}/{y}.png', {
                    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, '+
                                 ' <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>,'+
                                 ' Imagery © <a href="http://cloudmade.com">CloudMade</a>',
                    maxZoom: 18
                }).addTo(map);

                    var drawnItems = new L.FeatureGroup();
                    map.addLayer(drawnItems);

                    var drawControl = new L.Control.Draw({
                        draw: {
                        position: 'topleft',
                        polygon: {
                            shapeOptions: {
                                color: 'red',
                                opacity: 0.8
                            },
                            showArea: true
                        },
                        polyline: {
                            shapeOptions: {
                                color: 'green',
                                opacity: 0.8
                            },
                        },
                        rectangle: {
                            shapeOptions: {
                                color: 'blue',
                                opacity: 0.8
                            },
                        },
                        circle: {
                            shapeOptions: {
                                color: 'orange',
                                opacity: 0.8
                            }
                        }
                    },
                    edit: {
                        featureGroup: drawnItems
                    }
                });

                map.addControl(drawControl);
                
                function exportFeatures(featureGroup){
                    var mapdata = { center: map.getCenter(), 
                                    zoom:map.getZoom(), 
                                    geojson: }
                    for(item in featureGroup._layers) {
                        var feature = featureGroup._layers[item];
                        geoJsonFeature = feature.toGeoJSON()
                        if(feature.hasOwnProperty("_radius")) {
                            geoJsonFeature.geometry.radius = feature.getRadius();
                        }
                        geoJsonFeature.properties.color = feature.options.color;
                        mapdata.geojson[feature._leaflet_id] = geoJsonFeature;
                    }
                    $("input#mapdata").val(JSON.stringify(mapdata));
                }

                map.on('draw:created', function (e) {
                    var layer = e.layer;
                    drawnItems.addLayer(layer);
                    exportFeatures(drawnItems);
                });

                map.on('draw:edited', function (e) {
                    exportFeatures(drawnItems);
                });

                map.on('draw:deleted', function (e) {
                    exportFeatures(drawnItems);
                });

                map.on('dragend', function (e) {
                    exportFeatures(drawnItems);
                });

                map.on('zoomend', function (e) {
                    exportFeatures(drawnItems);
                });


            });
        </script>
        <form method="POST" action="/">
            <div id="map"></div>
            <input type="hidden" id="mapdata">
            <input type="submit">
        </form>
    </body>
</html>
```

**Disclaimer:** Somehow the article got crippled on the way through several static blog generators :unamused:

