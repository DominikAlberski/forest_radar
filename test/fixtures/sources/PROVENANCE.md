# Stage S fixture provenance

Stage S captured these public BDL responses on 2026-10-08 at 19:16–19:18 UTC.
The OGC responses contain self links. The self links below reproduce their exact request parameters.
The Stage S record omitted exact request URLs for several REST and WMS fixtures.
The remaining URLs below are reproducible requests. Their original parameter order is unverified.

| Fixture | Request URL |
| --- | --- |
| `collections.json` | `https://ogcapi.bdl.lasy.gov.pl/collections?f=json` |
| `rdlp-sample.json` | `https://ogcapi.bdl.lasy.gov.pl/collections/rdlp/items?f=json&bbox=20.6,52.25,20.8,52.35&limit=1&skipGeometry=true` |
| `district-box.json` | `https://ogcapi.bdl.lasy.gov.pl/collections/nadlesnictwa/items?f=json&bbox=20.6,52.25,20.8,52.35&limit=10&skipGeometry=true` |
| `range-sample.json` | `https://ogcapi.bdl.lasy.gov.pl/collections/lesnictwa/items?f=json&bbox=20.6,52.25,20.8,52.35&limit=1` |
| `stand-sample.json` | `https://ogcapi.bdl.lasy.gov.pl/collections/RDLP_Warszawa_wydzielenia/items?f=json&bbox=20.6,52.25,20.8,52.35&limit=1` |
| `stand-no-geometry.json` | `https://ogcapi.bdl.lasy.gov.pl/collections/RDLP_Warszawa_wydzielenia/items?f=json&bbox=20.6,52.25,20.8,52.35&limit=1&skipGeometry=true` |
| `stand-queryables.json` | `https://ogcapi.bdl.lasy.gov.pl/collections/RDLP_Warszawa_wydzielenia/queryables?f=json` |
| `tourism-wfs-capabilities.xml` | `https://mapserver.bdl.lasy.gov.pl/arcgis/services/WFS_BDL_mapa_turystyczna/MapServer/WFSServer?SERVICE=WFS&REQUEST=GetCapabilities` |
| `tourism-service.json` | `https://mapserver.bdl.lasy.gov.pl/arcgis/rest/services/WFS_BDL_mapa_turystyczna/MapServer?f=pjson` |
| `trail-layer.json` | `https://mapserver.bdl.lasy.gov.pl/arcgis/rest/services/WFS_BDL_mapa_turystyczna/MapServer/61?f=pjson` |
| `trail-query-sample.geojson` | `https://mapserver.bdl.lasy.gov.pl/arcgis/rest/services/WFS_BDL_mapa_turystyczna/MapServer/61/query?where=1%3D1&outFields=*&returnGeometry=true&outSR=4326&resultRecordCount=2&f=geojson` |
| `trail-types.json` | `https://mapserver.bdl.lasy.gov.pl/arcgis/rest/services/WFS_BDL_mapa_turystyczna/MapServer/61/query?where=1%3D1&outFields=tur_line_cd&returnDistinctValues=true&returnGeometry=false&f=pjson` |
| `walking-count.json` | `https://mapserver.bdl.lasy.gov.pl/arcgis/rest/services/WFS_BDL_mapa_turystyczna/MapServer/61/query?where=tur_line_cd%20LIKE%20%27%25PIESZ%25%27&returnCountOnly=true&f=pjson` |
| `tourism-capabilities.xml` | `https://mapserver.bdl.lasy.gov.pl/ArcGIS/services/WMS_BDL_Mapa_turystyczna/MapServer/WMSServer?SERVICE=WMS&REQUEST=GetCapabilities` |
| `tourism-wms-service.json` | `https://mapserver.bdl.lasy.gov.pl/arcgis/rest/services/WMS_BDL_Mapa_turystyczna/MapServer?f=pjson` |
| `bans-capabilities.xml` | `https://mapserver.bdl.lasy.gov.pl/ArcGIS/services/WMS_zakazy_wstepu_do_lasu/MapServer/WMSServer?SERVICE=WMS&REQUEST=GetCapabilities` |
| `bans-query-error.json` | `https://mapserver.bdl.lasy.gov.pl/ArcGIS/rest/services/WMS_zakazy_wstepu_do_lasu/MapServer/0/query?geometry=20.7%2C52.3&geometryType=esriGeometryPoint&inSR=4326&spatialRel=esriSpatialRelIntersects&outFields=%2A&returnGeometry=false&f=json` |

The original `trail-types.json` URL is absent from the Stage S record.
The worker fetched the reconstructed distinct query once on 2026-10-08 at 19:35 UTC.
The new JSON response matches the saved fixture after parsing. The exact original request remains unknown.
The worker fetched `bans-capabilities.xml` again on 2026-10-09 from its request URL above.
The live WMS lists only layers 0 to 2. None of those layers contains entry bans.
The ArcGIS REST service lists entry bans as layer 0.
The worker fetched `bans-query-error.json` on 2026-10-09 from its request URL above.
The ArcGIS REST layer 0 query returned error code 400 with message "Failed to execute query."
The `bans-query-empty.json` and `bans-query-feature.json` fixtures are synthetic.
