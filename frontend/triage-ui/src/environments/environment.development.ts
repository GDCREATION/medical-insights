export const environment = {
  production: false,
  apiBaseUrl: 'http://localhost:8080/api',
  auth0: {
    domain: 'dev-3lau552vpf734fpb.us.auth0.com', // e.g., dev-abc123.auth0.com
    clientId: 'CLGAnwA4AXTVHYBJeEMcT0NX5y4ytiME',
    audience: 'https://api.medical-insights.com', // Your API identifier in Auth0
    redirectUri: window.location.origin,
  },
};

