import requests
import json

overpass_url = 'http://overpass-api.de/api/interpreter'
# Sefrou coordinates
overpass_query = """
[out:json];
node["amenity"="pharmacy"](33.80, -4.86, 33.86, -4.80);
out body;
"""

try:
    response = requests.get(overpass_url, params={'data': overpass_query})
    data = response.json()

    pharmacies = []
    for element in data['elements']:
        if element['type'] == 'node':
            p = {
                'id': str(element['id']),
                'name': element.get('tags', {}).get('name', 'Pharmacie'),
                'address': element.get('tags', {}).get('addr:street', 'Sefrou'),
                'phone': element.get('tags', {}).get('phone', 'N/A'),
                'latitude': element['lat'],
                'longitude': element['lon'],
                'isOpen': True,
                'isDuty': False
            }
            pharmacies.append(p)

    with open('pharmacies_sefrou.json', 'w', encoding='utf-8') as f:
        json.dump(pharmacies, f, indent=2, ensure_ascii=False)
    
    print(f"Successfully fetched {len(pharmacies)} pharmacies.")
except Exception as e:
    print(f"Error: {e}")
