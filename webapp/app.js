const DEFAULT_RADIUS_METERS = 120;
const DEFAULT_MOCK_LISTINGS = [
  {
    id: "mock-1",
    address: "111 5th Ave, New York, NY",
    price: 1850000,
    lat: 40.7398,
    lng: -73.9897,
    status: "for_sale"
  },
  {
    id: "mock-2",
    address: "450 W 31st St, New York, NY",
    price: 1325000,
    lat: 40.7514,
    lng: -73.9968,
    status: "for_sale"
  }
];

let map;
let userMarker;
let watchId;
let listings = [];
const listingMarkers = new Map();
const announcedListings = new Set();

const statusEl = document.getElementById("status");
const startButton = document.getElementById("startButton");
const mapsApiKeyInput = document.getElementById("mapsApiKey");
const mlsApiUrlInput = document.getElementById("mlsApiUrl");

function setStatus(text) {
  statusEl.textContent = text;
}

function loadGoogleMaps(apiKey) {
  return new Promise((resolve, reject) => {
    if (window.google?.maps) {
      resolve();
      return;
    }

    const script = document.createElement("script");
    script.src = `https://maps.googleapis.com/maps/api/js?key=${encodeURIComponent(apiKey)}&v=weekly`;
    script.async = true;
    script.onerror = () => reject(new Error("Failed to load Google Maps script."));
    script.onload = () => resolve();
    document.head.appendChild(script);
  });
}

function initMap(initialPosition) {
  map = new google.maps.Map(document.getElementById("map"), {
    zoom: 15,
    center: initialPosition,
    mapTypeControl: false,
    streetViewControl: false
  });

  userMarker = new google.maps.Marker({
    map,
    position: initialPosition,
    title: "Your location",
    icon: "https://maps.google.com/mapfiles/ms/icons/blue-dot.png"
  });
}

function haversineMeters(a, b) {
  const toRad = (deg) => deg * Math.PI / 180;
  const earthRadius = 6371000;
  const dLat = toRad(b.lat - a.lat);
  const dLng = toRad(b.lng - a.lng);
  const lat1 = toRad(a.lat);
  const lat2 = toRad(b.lat);
  const h = Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLng / 2) ** 2;
  return 2 * earthRadius * Math.asin(Math.sqrt(h));
}

function priceLabel(price) {
  return Number(price).toLocaleString("en-US", {
    style: "currency",
    currency: "USD",
    maximumFractionDigits: 0
  });
}

function stableIdFromListing(raw) {
  const source = `${raw.address ?? ""}|${raw.lat ?? ""}|${raw.lng ?? ""}|${raw.price ?? ""}`;
  let hash = 0;
  for (let i = 0; i < source.length; i += 1) {
    hash = (hash * 31 + source.charCodeAt(i)) >>> 0;
  }
  return `generated-${hash.toString(16)}`;
}

function normalizeListing(raw) {
  return {
    id: String(raw.id ?? stableIdFromListing(raw)),
    address: String(raw.address ?? "Unknown address"),
    price: Number(raw.price ?? 0),
    lat: Number(raw.lat),
    lng: Number(raw.lng),
    status: String(raw.status ?? "for_sale").toLowerCase()
  };
}

async function fetchListings(position) {
  const endpoint = mlsApiUrlInput.value.trim();
  if (!endpoint) {
    setStatus("No MLS endpoint set. Using sample listing data.");
    return DEFAULT_MOCK_LISTINGS.map(normalizeListing);
  }

  const url = new URL(endpoint);
  url.searchParams.set("lat", String(position.lat));
  url.searchParams.set("lng", String(position.lng));

  const response = await fetch(url.toString());
  if (!response.ok) {
    throw new Error(`MLS API request failed: ${response.status}`);
  }

  const payload = await response.json();
  const source = Array.isArray(payload) ? payload : payload.listings;
  if (!Array.isArray(source)) {
    throw new Error("MLS API payload must be an array or { listings: [] }.");
  }

  return source.map(normalizeListing);
}

function syncListingMarkers() {
  const activeIds = new Set(listings.map((listing) => listing.id));

  listings.forEach((listing) => {
    if (!listingMarkers.has(listing.id)) {
      const marker = new google.maps.Marker({
        map,
        position: { lat: listing.lat, lng: listing.lng },
        title: `${listing.address} - ${priceLabel(listing.price)}`
      });
      listingMarkers.set(listing.id, marker);
    } else {
      listingMarkers.get(listing.id).setPosition({ lat: listing.lat, lng: listing.lng });
    }
  });

  for (const [id, marker] of listingMarkers.entries()) {
    if (!activeIds.has(id)) {
      marker.setMap(null);
      listingMarkers.delete(id);
      announcedListings.delete(id);
    }
  }
}

function announce(text) {
  if (!("speechSynthesis" in window)) {
    return;
  }

  const utterance = new SpeechSynthesisUtterance(text);
  utterance.lang = "en-US";
  window.speechSynthesis.speak(utterance);
}

function checkNearbyListings(position) {
  const nearby = listings.filter((listing) => {
    if (listing.status !== "for_sale") {
      return false;
    }
    const distance = haversineMeters(position, listing);
    return distance <= DEFAULT_RADIUS_METERS;
  });

  nearby.forEach((listing) => {
    if (announcedListings.has(listing.id)) {
      return;
    }
    announcedListings.add(listing.id);
    announce(`For sale. ${listing.address}. Price ${priceLabel(listing.price)}.`);
  });
}

function updateUserPosition(position) {
  userMarker.setPosition(position);
  map.setCenter(position);
}

async function updateListingsNear(position) {
  try {
    listings = await fetchListings(position);
    syncListingMarkers();
    checkNearbyListings(position);
  } catch (error) {
    setStatus(error.message);
  }
}

async function startTracking() {
  const apiKey = mapsApiKeyInput.value.trim();
  if (!apiKey) {
    setStatus("Enter a Google Maps API key.");
    return;
  }

  if (!("geolocation" in navigator)) {
    setStatus("Geolocation is not supported in this browser.");
    return;
  }

  setStatus("Loading map...");

  try {
    await loadGoogleMaps(apiKey);
  } catch (error) {
    setStatus(error.message);
    return;
  }

  navigator.geolocation.getCurrentPosition(async ({ coords }) => {
    const initialPosition = { lat: coords.latitude, lng: coords.longitude };
    if (!map) {
      initMap(initialPosition);
    }
    updateUserPosition(initialPosition);
    await updateListingsNear(initialPosition);
    setStatus("Tracking started.");
  }, () => {
    setStatus("Unable to access your location.");
  }, {
    enableHighAccuracy: true,
    timeout: 12000
  });

  if (watchId !== undefined) {
    navigator.geolocation.clearWatch(watchId);
  }

  watchId = navigator.geolocation.watchPosition(async ({ coords }) => {
    const current = { lat: coords.latitude, lng: coords.longitude };
    updateUserPosition(current);
    await updateListingsNear(current);
  }, () => {
    setStatus("Location tracking interrupted.");
  }, {
    enableHighAccuracy: true,
    maximumAge: 5000,
    timeout: 10000
  });
}

startButton.addEventListener("click", () => {
  startTracking();
});
