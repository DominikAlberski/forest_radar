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
| `bans-featureinfo-geojson.json` | `https://mapserver.bdl.lasy.gov.pl/ArcGIS/services/WMS_zakazy_wstepu_do_lasu/MapServer/WMSServer?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetFeatureInfo&LAYERS=3&QUERY_LAYERS=3&CRS=CRS:84&BBOX=20.6,52.25,20.8,52.35&WIDTH=101&HEIGHT=101&I=50&J=50&FEATURE_COUNT=10&INFO_FORMAT=application%2Fgeo%2Bjson` |

The original `trail-types.json` URL is absent from the Stage S record.
The worker fetched the reconstructed distinct query once on 2026-10-08 at 19:35 UTC.
The new JSON response matches the saved fixture after parsing. The exact original request remains unknown.
The `bans-featureinfo-geojson.json` fixture has normalized line endings.
