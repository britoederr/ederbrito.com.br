Country Snapshot API

This is the strongest one.

A user enters a country name and gets a compact snapshot:

population
GDP / GDP per capita
inflation
unemployment
internet usage
CO2 emissions
recent weather summary for the capital
research output trend

You can source that from:

World Bank Indicators API for country indicators, which exposes nearly 16,000 time-series indicators across decades.
Open-Meteo for forecast and climate/weather data, which offers a free API and documents forecast and climate endpoints.
OpenAlex for research metadata and publication trends; its API covers works, authors, institutions, topics, and more, and basic queries do not require an API key.

Why this works well:

instantly understandable
globally useful
easy to demo on your site
naturally creates fan-out traces and cache behavior

Good endpoint shape:

GET /api/country-snapshot?country=brazil

This is my top recommendation.