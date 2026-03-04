// import leaflet from "../node_modules/leaflet/";
// import { leaflet} from 'leaflet';
import 'leaflet';
// import css for markercluster
import 'leaflet.markercluster';
import { ZoomDependentExpression } from 'maplibre-gl';
// import "leaflet.markercluster/dist/MarkerCluster.Default.css";
// import "leaflet.markercluster/dist/MarkerCluster.css"

// from the solidstart working app
// // import css for markercluster
// import 'leaflet.markercluster';
// import "leaflet.markercluster/dist/MarkerCluster.Default.css";
// import "leaflet.markercluster/dist/MarkerCluster.css"

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

const getFormattedBounds = (map) => {
  const newBoundsFromLeaflet = map.getBounds();

  const newBounds = {
    northEast: newBoundsFromLeaflet.getNorthEast(),
    southWest: newBoundsFromLeaflet.getSouthWest()
  };

  const newMapCenter = map.getCenter();

  const newZoom = map.getZoom();

  const formattedBounds = {
    neLat: newBounds.northEast.lat,
    neLon: newBounds.northEast.lng,
    swLat: newBounds.southWest.lat,
    swLon: newBounds.southWest.lng,
    mapCenterLat: newMapCenter.lat,
    mapCenterLon: newMapCenter.lng,
    mapZoom: newZoom
  };

  return formattedBounds;
} // end function getFormattedBounds(map)

const leafletHook = {



  mounted() {
    /* CHECK IF WE SUPPORT TOUCH INPUT -- IF SO WE WILL DISABLE HOVER LABELS*/
    const browserSupportsTouch = navigator.maxTouchPoints > 0;
    if (browserSupportsTouch) {
      console.log("SUPPORTS TOUCH!")
    }

    params = new URLSearchParams(window.location.search);
    // console.log (params)

    var map = L.map(this.el)

    // initialize map layer for physicians
    let docLayer;

    if (
      params.has("mapCenterLat") &&
      params.has("mapCenterLon") &&
      params.has("mapZoom")
    ) {
      map.setView([params.get("mapCenterLat"), params.get("mapCenterLon")], params.get("mapZoom"));
      // drop a marker at the map centre
      // L.marker([params.get("mapCenterLat"),  params.get("mapCenterLon")]).addTo(map)
      //     .bindPopup('A pretty CSS popup.<br> Easily customizable.')
      //     .openPopup();
    } else {
      map.setView([45.40977921176112, -75.6670323159904], 13);
      // L.marker([51.505, -0.09]).addTo(map)
      //     .bindPopup('A pretty CSS popup.<br> Easily customizable.')
      //     .openPopup();
    }

    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);




    // test handling event to add a marker
    this.handleEvent("A", (spec) => {
      console.log("add-random-marker received")
      formattedBounds = getFormattedBounds(map);
      const newLat = formattedBounds.mapCenterLat + (Math.random() - 0.5) / 10;
      const newLon = formattedBounds.mapCenterLon + (Math.random() - 0.5) / 10;

      console.log("adding a random marker at ", newLat, ", ", newLon)
      L.marker([newLat, newLon]).addTo(map)
    })

    // test handling event where new parameters are pushed, we may need to update the map
    // primarily this will be loading a page for the first time with specific query parameters
    // i.e. making sure that the url query parameters (interpreted and sent by the server) match the 
    // actual boundaries of the map in the client. 
    // if they match, we do nothing.
    // if they don't match, we update the map on the client.
    this.handleEvent("update-map-boundaries", (serverBounds) => {
      console.log("update-map-boundaries received")

      // convert string values to floats
      Object.keys(serverBounds).forEach(
        (key, _index) => serverBounds[key] = parseFloat(serverBounds[key])
      );

      // console.log(serverBounds)
      clientBounds = getFormattedBounds(map);

      // check if client and server are in sync; if so, we stop here and return
      if (
        serverBounds.mapCenterLat === clientBounds.mapCenterLat &&
        serverBounds.mapCenterLon === clientBounds.mapCenterLon &&
        serverBounds.mapZoom === clientBounds.mapZoom &&
        serverBounds.neLat === clientBounds.neLat &&
        serverBounds.swLat === clientBounds.swLat &&
        serverBounds.swLon === clientBounds.swLon
      ) {
        console.log("no change")
        return;
      }


      // console.log(JSON.stringify(serverBounds))
      // console.log(JSON.stringify(clientBounds))

      // the server and client params are out of sync, so update the client to match the server
      map.setView([serverBounds.mapCenterLat, serverBounds.mapCenterLon]).setZoom(serverBounds.mapZoom);

    }) // end  this.handleEvent("update-map-boundaries", ...


    // add event listener on drag/zoom to link search area to map bounds
    map.addEventListener("dragend zoom", () => {

      formattedBounds = getFormattedBounds(map);
      // console.log(formattedBounds)
      this.pushEvent("map-boundaries-change", formattedBounds)

    }) // end map.addEventListener("dragend zoom"...


    // new docs from server!
    this.handleEvent("new-docs", (spec) => {

      const locale = (new URLSearchParams(window.location.search)).get("locale") ?? "en"

      if (locale == "en") {
        textMore = "More than 100 results found. Zoom in to see more!";
        textNone = "No results found. Try moving the map or changing your search criteria.";
      } else {
        textMore = "Plus de 100 résultats trouvés. Zoomez pour en voir davantage !";
        textNone = "Aucun résultat trouvé. Essayez de déplacer la carte ou de modifier vos critères de recherche.";
        
      }

      console.log(locale)

      const docs = JSON.parse(spec.data)

      // show toast if >100 docs
      const toast = document.getElementById("toast")

      if (docs.length >= 100) {
        toast.textContent = textMore;
        toast.classList.remove("hidden")
      } else if (docs.length == 0) {
        toast.textContent = textNone;
        toast.classList.remove("hidden")
      } else {
        toast.classList.add("hidden")
      }

      // remove previous docs
      // only remove the layer if it has been defined
      if (docLayer) { map.removeLayer(docLayer) }

      // add the docs here.. 
      realDocMarkers = docs.map((doc) => {
        if (!doc) return null;
        if (!doc.lat || !doc.lon) return null;

        const label = (`
        <div style="max-width:300px; overflow-wrap: break-word !important; word-break: break-word !important;">
                <b>Name:</b> ${doc.name}
                <br><b>Gender:</b> ${doc.gender}
                <br><b>Specialty:</b> ${doc.specialty}
                <br><b>Languages:</b> ${doc.languages_spoken}                
                <br><b>Address:</b> ${doc.primary_location}
                ${doc.phone_number !== "NA" ? "<br><b>Phone Number:</b> " + doc.phone_number : ""}
        </div>`)

        const newMarker = L.marker([doc.lat, doc.lon])
          .bindPopup(label);

        // only bind tooltips if they're not using a touch browser
        if (!browserSupportsTouch) {
          newMarker.bindTooltip(label, { className: 'myTooltip' });
        } // end if (!browserSupportsTouch)

        return newMarker;
      }).flatMap((docMarker) => docMarker ? [docMarker] : []);


      // console.log(realDocMarkers)
      // add markers to layer
      // docLayer = L.layerGroup(realDocMarkers)
      // docLayer = L.markerClusterGroup(realDocMarkers) ;
      // add layer to map
      // console.log(docLayer)

      // map.addLayer(docLayer);
      docLayer = L.markerClusterGroup({ animate: false });
      realDocMarkers.map(marker => docLayer.addLayer(marker))
      map.addLayer(docLayer);



    })


  }
};

export default leafletHook;
