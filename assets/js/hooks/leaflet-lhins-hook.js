
import 'leaflet';


// // manually import marker so it works in production
// import markerIcon from "leaflet/dist/images/marker-icon.png";
// import markerShadow from "leaflet/dist/images/marker-shadow.png";
// import retinaMarkerIcon from "leaflet/dist/images/marker-icon-2x.png";
// import toast, { Toaster } from 'solid-toast';
// import { MAX_SEARCH_RESULTS } from '~/lib/globals';

// L.Marker.prototype.setIcon(L.icon({
//     iconUrl: markerIcon,
//     shadowUrl: markerShadow,
//     iconRetinaUrl: retinaMarkerIcon,
//     iconSize: [25, 41],
//     iconAnchor: [13, 41]
// }))

//  import "../../vendor/node_modules/leaflet/dist/leaflet.css";

// .Icon.Default.prototype.options.iconUrl = "/images/marker-icon.png";

import lhins from './lhins';
const leafletLhinsHook = {



  mounted() {
    function getColor(d) {
      return d > 1000 ? '#800026' :
        d > 500 ? '#BD0026' :
          d > 200 ? '#E31A1C' :
            d > 100 ? '#FC4E2A' :
              d > 50 ? '#FD8D3C' :
                d > 20 ? '#FEB24C' :
                  d > 10 ? '#FED976' :
                    d >= 1 ? '#FFEDA0' :
                      "#FFF";
    };

    console.log("sadf")

    var map = L.map(document.getElementById('lhin-plot'));

    map.setView([46.40977921176112, -81.6670323159904], 5);
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);



    var legend = L.control({ position: 'bottomright' });

    legend.onAdd = function(map) {

      var div = L.DomUtil.create('div', 'info legend'),
        grades = [1, 10, 20, 50, 100, 200, 500, 1000],
        labels = [];

      // loop through our density intervals and generate a label with a colored square for each interval
      div.innerHTML += '<i style="background:' + getColor(0) + '"></i> 0<br>';
      for (var i = 0; i < grades.length; i++) {
        div.innerHTML +=
          '<i style="background:' + getColor(grades[i] + 1) + '"></i> ' +
          grades[i] + (grades[i + 1] ? '&ndash;' + grades[i + 1] + '<br>' : '+');
      }

      return div;
    };

    legend.addTo(map);
    var lhinLayer;


    // NEW DATA
    this.handleEvent("new-stats", stats => {
      console.log("leaflet got new data")


      if (lhinLayer) { lhinLayer.remove() }
      if (info) { info.remove() }

      // custom tooltip in custom control
      var info = L.control();

      info.onAdd = function(map) {
        this._div = L.DomUtil.create('div', 'info'); // create a div with a class "info"
        this.update();
        return this._div;
      };

      // method that we will use to update the control based on feature properties passed
      info.update = function(props) {
        // this._div.innerHTML = '<h4>US Population Density</h4>' + (props ?
        //   '<b>' + props.lhin + '</b><br />' + stats.lhins_n[feature.properties.lhin] + ' people / mi<sup>2</sup>'
        //   : 'Hover over a state');
      };

      info.addTo(map);

      function highlightFeature(e) {
        var layer = e.target;

        layer.setStyle({
          weight: 5,
          color: '#666',
          dashArray: '',
          fillOpacity: 0.7
        });

        layer.bringToFront();

        info.update(layer.feature.properties);
      }

      function resetHighlight(e) {
        lhinLayer.resetStyle(e.target);

        info.update();
      }

      function zoomToFeature(e) {
        map.fitBounds(e.target.getBounds());
      }
      function onEachFeature(feature, layer) {
        layer.on({
          mouseover: highlightFeature,
          mouseout: resetHighlight,
          click: zoomToFeature
        });
      }
      function style(feature) {
        return {
          fillColor: getColor(stats.lhins_n[feature.properties.lhin]),
          weight: 2,
          opacity: 1,
          color: 'white',
          dashArray: '3',
          fillOpacity: 0.7
        }
      }
      console.log(stats.lhins_n)

      max_val = Math.max(...Object.values(stats.lhins_n))
      min_val = Math.min(...Object.values(stats.lhins_n))

      lhinLayer = L.geoJSON(lhins, {
        style: style,
        onEachFeature: onEachFeature
      }).addTo(map);
    }) // end handleEvent("new-stats")
    console.log(lhins);
  }



};

export default leafletLhinsHook;
