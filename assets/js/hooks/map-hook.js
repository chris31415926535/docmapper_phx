
import { Map } from 'maplibre-gl';
// import "../../node_modules/maplibre-gl/dist/maplibre-gl.css"
const MapHook = {
  mounted() {
    console.log("hello");


    const map = new Map({
      container: 'map',
      style: 'https://demotiles.maplibre.org/style.json',
      center: [0, 0],
      zoom: 2
    });

    console.log(map);

  },

};

export default MapHook;
