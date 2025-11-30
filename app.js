// Sample destination data for the Travel App
const destinations = [
    { name: 'Paris, France', description: 'The City of Light, known for the Eiffel Tower, Louvre, and romance.' },
    { name: 'Tokyo, Japan', description: 'A blend of ultramodern and traditional, from neon-lit skyscrapers to temples.' },
    { name: 'New York City, USA', description: 'The Big Apple - Times Square, Central Park, and iconic skyline.' },
    { name: 'Barcelona, Spain', description: 'Gaudí architecture, beautiful beaches, and vibrant nightlife.' },
    { name: 'Sydney, Australia', description: 'Harbor views, Opera House, and stunning beaches like Bondi.' },
    { name: 'Rome, Italy', description: 'Ancient ruins, the Colosseum, Vatican City, and Italian cuisine.' },
    { name: 'London, UK', description: 'Royal palaces, Big Ben, West End theaters, and British culture.' },
    { name: 'Dubai, UAE', description: 'Futuristic architecture, luxury shopping, and desert adventures.' },
    { name: 'Bali, Indonesia', description: 'Tropical paradise with temples, rice terraces, and wellness retreats.' },
    { name: 'Cape Town, South Africa', description: 'Table Mountain, stunning coastlines, and diverse wildlife.' },
    { name: 'Machu Picchu, Peru', description: 'Ancient Incan citadel set high in the Andes Mountains.' },
    { name: 'Santorini, Greece', description: 'Iconic white-washed buildings, blue domes, and Mediterranean sunsets.' }
];

// DOM elements
const searchForm = document.getElementById('searchForm');
const searchInput = document.getElementById('searchInput');
const searchResults = document.getElementById('searchResults');

/**
 * Filter destinations based on search query
 * @param {string} query - The search query
 * @returns {Array} Filtered destinations
 */
function filterDestinations(query) {
    const searchTerm = query.toLowerCase().trim();
    
    if (!searchTerm) {
        return [];
    }
    
    return destinations.filter(destination => 
        destination.name.toLowerCase().includes(searchTerm) ||
        destination.description.toLowerCase().includes(searchTerm)
    );
}

/**
 * Render search results to the DOM
 * @param {Array} results - Array of destination objects
 * @param {string} query - The search query for display
 */
function renderResults(results, query) {
    searchResults.innerHTML = '';
    
    if (!query.trim()) {
        return;
    }
    
    if (results.length === 0) {
        const noResultsDiv = document.createElement('div');
        noResultsDiv.className = 'no-results';
        
        const heading = document.createElement('h3');
        heading.textContent = 'No destinations found';
        
        const message = document.createElement('p');
        message.textContent = 'Try searching for a different city or attraction.';
        
        noResultsDiv.appendChild(heading);
        noResultsDiv.appendChild(message);
        searchResults.appendChild(noResultsDiv);
        return;
    }
    
    results.forEach(destination => {
        const card = document.createElement('article');
        card.className = 'result-card';
        
        const title = document.createElement('h3');
        title.textContent = destination.name;
        
        const description = document.createElement('p');
        description.textContent = destination.description;
        
        card.appendChild(title);
        card.appendChild(description);
        searchResults.appendChild(card);
    });
}

/**
 * Handle search form submission
 * @param {Event} event - The form submit event
 */
function handleSearch(event) {
    event.preventDefault();
    const query = searchInput.value;
    const results = filterDestinations(query);
    renderResults(results, query);
}

/**
 * Handle real-time search as user types
 */
function handleInputChange() {
    const query = searchInput.value;
    const results = filterDestinations(query);
    renderResults(results, query);
}

// Event listeners
searchForm.addEventListener('submit', handleSearch);
searchInput.addEventListener('input', handleInputChange);

// Focus the search input on page load
window.addEventListener('load', () => {
    searchInput.focus();
});
