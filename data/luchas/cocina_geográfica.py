import pandas as pd
from geopy.geocoders import Nominatim
from geopy.exc import GeocoderTimedOut, GeocoderServiceError
import time
import os
from tqdm import tqdm

input_csv_path = os.path.join('data', 'luchas', 'events.csv')
output_csv_path = os.path.join('data', 'luchas', 'events_con_coordenadas.csv')

# Parámetros para hacer el script más robusto
TIMEOUT_SEGUNDOS = 15
NUMERO_DE_REINTENTOS = 3
PAUSA_ENTRE_REINTENTOS = 2

try:
    print(f"Leyendo el archivo CSV desde: {input_csv_path}")
    df = pd.read_csv(input_csv_path)
except FileNotFoundError:
    print(f"Error: No se encontró el archivo en la ruta especificada: {input_csv_path}")
    exit()

if 'location' not in df.columns:
    print("Error: El archivo CSV no contiene una columna llamada 'location'.")
    exit()

# Limpiar espacios en blanco extra y filtrar valores nulos antes de obtener únicos
unique_locations = df['location'].str.strip().dropna().unique()
print(f"Se han encontrado {len(unique_locations)} ubicaciones únicas para geocodificar.")

# inicializar el geocodificador
geolocator = Nominatim(user_agent="proyecto_universitario_mma_robusto_v2", timeout=TIMEOUT_SEGUNDOS)
coordenadas_cache = {}

print("\nIniciando el proceso de geocodificación robusta con fallback...")

#Repetir para cada ubicación única
for location_name in tqdm(unique_locations, desc="Geocodificando ubicaciones"):
    location_data = None # Reseteamos la variable en cada iteración
    for intento in range(NUMERO_DE_REINTENTOS):
        try:

            # Intento 1: Usar el nombre completo y específico de la ubicación
            location_data = geolocator.geocode(location_name)

            # Intento 2: Si el nombre completo falla, simplificarlo
            if location_data is None:
                parts = [p.strip() for p in location_name.split(',')]
                # Si hay más de 2 partes (ej. Venue, City, Country), quitamos la primera
                if len(parts) > 2:
                    simplified_location = ', '.join(parts[1:])
                    # Usamos tqdm.write para no romper la barra de progreso
                    tqdm.write(f"'{location_name}' no encontrado. Intentando con una ubicación simplificada: '{simplified_location}'")
                    location_data = geolocator.geocode(simplified_location)
            #guardamos el resultado
    
            if location_data:
                coordenadas_cache[location_name] = (location_data.latitude, location_data.longitude)
            else:
                # Si después de ambos intentos no se encuentra, se marca como None
                coordenadas_cache[location_name] = (None, None)
            
            # Si la petición tuvo éxito (o falló definitivamente), salimos del bucle de reintentos
            break
            
        except (GeocoderTimedOut, GeocoderServiceError) as e:
            tqdm.write(f"Intento {intento + 1}/{NUMERO_DE_REINTENTOS} fallido para '{location_name}': {e}. Reintentando en {PAUSA_ENTRE_REINTENTOS}s...")
            if intento + 1 == NUMERO_DE_REINTENTOS:
                 coordenadas_cache[location_name] = (None, None)
                 tqdm.write(f"No se pudieron obtener las coordenadas para '{location_name}' después de {NUMERO_DE_REINTENTOS} intentos.")
            time.sleep(PAUSA_ENTRE_REINTENTOS)
            
    # Pausa obligatoria entre diferentes ubicaciones para respetar los límites de la API de Nominatim
    time.sleep(1)

# añadir coordenadas
print("\nAñadiendo las coordenadas al DataFrame...")
df['latitud'] = df['location'].map(lambda loc: coordenadas_cache.get(loc, (None, None))[0])
df['longitud'] = df['location'].map(lambda loc: coordenadas_cache.get(loc, (None, None))[1])

# guardar los resultados
print("\nGuardando los resultados en un archivo CSV...")
df.to_csv(output_csv_path, index=False, encoding='utf-8-sig')

print("\n¡Proceso completado con éxito!")
print(f"Los datos con las coordenadas se han guardado en: {output_csv_path}")

no_encontrados = df['latitud'].isna().sum()
encontrados = len(df) - no_encontrados
print(f"Resumen: Se procesaron {len(df)} eventos.")
print(f" -> Coordenadas encontradas para {encontrados} eventos.")
print(f" -> No se encontraron coordenadas para {no_encontrados} eventos.")