# Build a Small Rails-Style Endpoint

A small API-only Rails application implementing the baseline monthly-comparison endpoint.

## Endpoint implemented

`GET /api/challenge/monthly-comparison`

Example

```sh
curl 'http://localhost:3000/api/challenge/monthly-comparison?store_id=demo-auckland&months=24'
```

```sh
curl 'http://localhost:3000/api/challenge/monthly-comparison?store_id=demo-auckland&category_id=fiction'
```
