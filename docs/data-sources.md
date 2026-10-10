# Data sources

All endpoints below are public. No key is needed. BDL and Overpass contracts were rechecked on 2026-10-08.

## 1. Bank Danych o Lasach — OGC API Features

Base URL: `https://ogcapi.bdl.lasy.gov.pl`

This service returns vector features as GeoJSON. Use the parameter `f=json`.

### Collections

| Collection id | Holds | Count (checked) |
| --- | --- | --- |
| `rdlp` | The 17 regional directorates, as polygons | 17 |
| `nadlesnictwa` | The 429 forest districts, as polygons | 429 |
| `lesnictwa` | The forest ranges, as polygons | — |
| `RDLP_<Region>_wydzielenia` | The forest stands of one region | 74,338 in Warszawa |

The stand collections are split by region. Region ids: `Bialystok`, `Katowice`, `Krakow`, `Krosno`, `Lublin`, `Lodz`, `Olsztyn`, `Pila`, `Poznan`, `Szczecin`, `Szczecinek`, `Torun`, `Wroclaw`, `Zielona_Gora`, `Gdansk`, `Radom`, `Warszawa`.

### Read the features in a box

```text
GET https://ogcapi.bdl.lasy.gov.pl/collections/RDLP_Warszawa_wydzielenia/items?bbox=20.6,52.25,20.8,52.35&limit=2&f=json
```

The bounding box order is `lon,lat,lon,lat` in CRS84. `limit=2` returns two features.
Read pages with explicit offsets. The first page's `numberMatched` gives the full count for the box.
Later pages report the count minus the offset. See [ADR 0009](decisions/0009-bdl-offset-pagination.md).

### Verified sample response

A request for the Kampinos area returned:

```json
{
  "adr_for": "17-05-1-04-244B  -f   -00",
  "site_type": "BMŚW",
  "forest_fun": "GOSP",
  "rotat_age": 120,
  "prot_categ": null,
  "part_cd": "10",
  "spec_age": 70,
  "nazwa": "BDL_17_05_JABLONNA_2026",
  "area_type": "D-STAN",
  "a_i_num": 1705016744,
  "silvicult": "Z",
  "stand_stru": "DRZEW",
  "sub_area": 0.15,
  "species_cd": "SO",
  "a_year": 2026
}
```

The response also holds the geometry for each feature.

### The stand attributes

| Field | Meaning | Example |
| --- | --- | --- |
| `species_cd` | The main tree species | `SO` = Scots pine |
| `site_type` | The habitat type | `BMŚW` = fresh mixed conifer |
| `spec_age` | The age of the trees, in years | `70` |
| `rotat_age` | The rotation age | `120` |
| `sub_area` | The area, in hectares | `0.15` |
| `prot_categ` | The protection category | `null` when none |
| `forest_fun` | The function of the forest | `GOSP` = production |
| `adr_for` | The forest address | `17-05-1-04-244B` |
| `nazwa` | The district name in the dataset | `BDL_17_05_JABLONNA_2026` |
| `a_i_num` | The numeric identifier | `1705016744` |
| `a_year` | The data year | `2026` |

The queryable fields are at `GET /collections/{id}/queryables?f=json`.

### The address encodes the place

`a_i_num` starts with the region code. `17` is Warszawa. `17-05` is the district. Use `a_i_num` to group the stands by district.

### Entry bans (removed)

The entry ban check was removed because the live BDL layer returns HTTP 400 and cannot provide reliable access evidence. See [ADR 0007](decisions/0007-remove-entry-ban-check.md).

## 2. Tourist data — WMS

```text
https://mapserver.bdl.lasy.gov.pl/ArcGIS/services/WMS_BDL_Mapa_turystyczna/MapServer/WMSServer
```

Layers include:

- areas of the program "Zanocuj w lesie"
- horse trails. The checked BDL tourism data supplied no verified walking-trail geometry.
- educational paths
- tourism infrastructure: shelters and rest areas
- cultural heritage objects

## 3. Other BDL services

| Service | Address | Use |
| --- | --- | --- |
| Fire risk zones | `.../WMS_zagrozenie_pozarowe_w_lasach/MapServer/WMSServer` | Add a fire warning to the card |
| Hunting districts | `.../WMS_Obwody_lowieckie/MapServer/WMSServer` | Show the hunting context |
| WFS | `https://wfs.bdl.lasy.gov.pl/geoserver/BDL/ows` | An alternative to OGC API |
| Portal | `https://www.bdl.lasy.gov.pl/portal/` | Manual download of shapefiles |

## 4. What the data does NOT hold

The API has no field for mushrooms, for berries, for dogs, or for animal tracks. Do not look for these fields.

The model derives this advice from `species_cd`, `site_type`, `spec_age`, the season, and the region. This is inference, not data. The card must say so.

## 5. Politeness

The service is public and shared. Cache every response for the session. Send one request per area, not one per user action.

## 6. OpenStreetMap walking trails

The application reads `route=hiking`, `route=foot`, and `route=walking` relations through Overpass.
The checked response contains member way geometry for range 5157 and range 5172.
The Overpass service is shared and can fail or return stale data.
An absent route relation does not prove that no walking trail exists on the ground.
The data licence is ODbL. Show © OpenStreetMap contributors and link to https://www.openstreetmap.org/copyright.

The recorded BDL range pages report `numberMatched` values 2 and 1.
The page-2 self link omits `offset`. The observed range IDs do not prove pagination completeness.

## 7. Reference

- Forest Data Bank: `https://www.bdl.lasy.gov.pl/portal/en`
- OGC API Features training material (Polish): `https://www.ekoportal.gov.pl`
