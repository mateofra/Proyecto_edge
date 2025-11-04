import pandas as pd
from geopy.geocoders import Nominatim
from geopy.exc import GeocoderTimedOut, GeocoderServiceError
import time
import os
from tqdm import tqdm  # Importar tqdm para la barra de progreso

# --- 1. CONFIGURACIÓN MEJORADA ---
input_csv_path = os.path.join('data', 'luchas', 'events.csv')
output_csv_path = os.path.join('data', 'luchas', 'events_con_coordenadas.csv')

# Parámetros para hacer el script más robusto
TIMEOUT_SEGUNDOS = 15  # Aumentamos el tiempo de espera a 15 segundos
NUMERO_DE_REINTENTOS = 3 # Intentará cada petición hasta 3 veces si falla
PAUSA_ENTRE_REINTENTOS = 2 # Esperará 2 segundos antes de reintentar

# --- 2. LECTURA DEL ARCHIVO CSV ---
try:
    print(f"Leyendo el archivo CSV desde: {input_csv_path}")
    df = pd.read_csv(input_csv_path)
except FileNotFoundError:
    print(f"Error: No se encontró el archivo en la ruta especificada: {input_csv_path}")
    exit()

if 'location' not in df.columns:
    print("Error: El archivo CSV no contiene una columna llamada 'location'.")
    exit()

# --- 3. OBTENER UBICACIONES ÚNICAS ---
unique_locations = df['location'].dropna().unique()
print(f"Se han encontrado {len(unique_locations)} ubicaciones únicas para geocodificar.")

# --- 4. GEOCODIFICACIÓN ROBUSTA CON REINTENTOS Y BARRA DE PROGRESO ---
# Inicializar el geocodificador con el nuevo timeout
geolocator = Nominatim(user_agent="proyecto_universitario_mma_robusto", timeout=TIMEOUT_SEGUNDOS)
coordenadas_cache = {}

print("\nIniciando el proceso de geocodificación robusta...")

# Usamos tqdm para envolver la lista y crear una barra de progreso
for location_name in tqdm(unique_locations, desc="Geocodificando ubicaciones"):
    # Bucle de reintentos
    for intento in range(NUMERO_DE_REINTENTOS):
        try:
            location_data = geolocator.geocode(location_name)
            if location_data:
                coordenadas_cache[location_name] = (location_data.latitude, location_data.longitude)
            else:
                coordenadas_cache[location_name] = (None, None)
            
            # Si la petición tuvo éxito, salimos del bucle de reintentos
            break
            
        except (GeocoderTimedOut, GeocoderServiceError) as e:
            # Si el error es un timeout o de servicio, lo notificamos y reintentamos
            # tqdm.write() es como print() pero no interfiere con la barra de progreso
            tqdm.write(f"Intento {intento + 1}/{NUMERO_DE_REINTENTOS} fallido para '{location_name}': {e}. Reintentando en {PAUSA_ENTRE_REINTENTOS}s...")
            if intento + 1 == NUMERO_DE_REINTENTOS: # Si es el último intento
                 coordenadas_cache[location_name] = (None, None) # Marcar como no encontrado
                 tqdm.write(f"No se pudieron obtener las coordenadas para '{location_name}' después de {NUMERO_DE_REINTENTOS} intentos.")
            time.sleep(PAUSA_ENTRE_REINTENTOS)
            
    # Pausa obligatoria entre diferentes ubicaciones para respetar los límites de la API
    time.sleep(1)

# --- 5. AÑADIR LAS COORDENADAS AL DATAFRAME ORIGINAL ---
print("\nAñadiendo las coordenadas al DataFrame...")
df['latitud'] = df['location'].map(lambda loc: coordenadas_cache.get(loc, (None, None))[0])
df['longitud'] = df['location'].map(lambda loc: coordenadas_cache.get(loc, (None, None))[1])

# --- 6. GUARDAR LOS RESULTADOS ---
df.to_csv(output_csv_path, index=False, encoding='utf-8-sig')

print("\n¡Proceso completado con éxito!")
print(f"Los datos con las coordenadas se han guardado en: {output_csv_path}")

# Contar cuántos no se encontraron
no_encontrados = df['latitud'].isna().sum()
print(f"Resumen: Se procesaron {len(df)} eventos. No se encontraron coordenadas para {no_encontrados} de ellos.")