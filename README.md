# General course assignment

Build a map-based application, which lets the user see geo-based data on a map and filter/search through it in a meaningfull way. Specify the details and build it in your language of choice. The application should have 3 components:

1. Custom-styled background map, ideally built with [mapbox](http://mapbox.com). Hard-core mode: you can also serve the map tiles yourself using [mapnik](http://mapnik.org/) or similar tool.
2. Local server with [PostGIS](http://postgis.net/) and an API layer that exposes data in a [geojson format](http://geojson.org/).
3. The user-facing application (web, android, ios, your choice..) which calls the API and lets the user see and navigate in the map and shows the geodata. You can (and should) use existing components, such as the Mapbox SDK, or [Leaflet](http://leafletjs.com/).

## Data sources

- [Mass.gov](https://www.mass.gov/service-details/massgis-data-layers)

## My project

**Application description**:

iOS application which can display the following use cases on Mapbox map:

- Massachusetts forest coverage 
- The nearest railway stations to the selected prison
- The shortest route from railway station A to railway station B
- The shortest route from railway station A to railway station B with a stop in the station C
- Cycle route which has the most intersection with rivers

**Data source**:
- [Mass.gov](https://www.mass.gov/service-details/massgis-data-layers)

**Technologies used**:

- Flask
- Swift 
- Mapbox SDK for iOS
