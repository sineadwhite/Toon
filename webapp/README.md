# NY Listings Drive-By Announcer (Web)

This folder contains a standalone web app that:

- loads Google Maps
- tracks your live location in the browser
- pulls nearby listings from a New York MLS-compatible endpoint
- announces the sale price and address when you pass close to a listing

## Run

Serve the folder from any local web server, then open `index.html` in a browser with location access enabled.

Example:

```bash
cd /home/runner/work/Toon/Toon/webapp
python3 -m http.server 8080
```

Then open `http://localhost:8080`.

## Inputs

The app asks for:

1. **Google Maps API Key** (Maps JavaScript API enabled)
2. **NY MLS Feed URL** (your own backend/API endpoint)

The endpoint should return either:

- an array of listings, or
- `{ "listings": [...] }`

Each listing should include:

```json
{
  "id": "listing-id",
  "address": "123 Main St, New York, NY",
  "price": 1250000,
  "lat": 40.7128,
  "lng": -74.006,
  "status": "for_sale"
}
```

If no endpoint is provided, the app uses built-in sample listing data.

## Notes

- Browser geolocation and text-to-speech permissions must be allowed.
- Real NY MLS data access usually requires a licensed feed (for example via REBNY/RLS or a broker-approved data provider) and a backend that handles authentication and compliance.
