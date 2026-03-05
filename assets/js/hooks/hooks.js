// Consolidate all individual hooks into one object that we load in app.js
// 
import MapHook from "./map-hook";
import LeafletHook from "./leaflet";
import LeafletLhinsHook from "./leaflet-lhins-hook";
export default {
  MapHook,
  LeafletHook,
  LeafletLhinsHook
};
