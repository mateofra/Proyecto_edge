import pandas as pd
from geopy.geocoders import Nominatim
import time
import os
from tqdm import tqdm

if __name__ == "__main__":
    # Directorios input y output
    input_csv_path = 'data/luchas/events.csv'
    output_csv_path = 'data/luchas/events_con_coordenadas.csv'
    
    # Leer el archivo CSV
    
    try:
        print(f"Leyendo el archivo CSV desde: {input_csv_path}")
        df = pd.read_csv(input_csv_path)
    except FileNotFoundError:
        print(f"Error: No se encontró el archivo 'events.csv' en: {input_csv_path}")
        exit()
    
    # Obtener las ubicaciones únicas
    
    unique_locations = df['location'].str.strip().dropna().unique()
    print(f"Se han encontrado {len(unique_locations)} ubicaciones únicas para geocodificar.")
    
    # Inicializar el geocodificador y el caché de coordenadas
    
    geolocator = Nominatim(user_agent="proyecto_EDGE", timeout=15)
    coordenadas_cache = {}
    
    print("\nIniciando el proceso de geocodificación :)")
    
    for location_name in tqdm(unique_locations, desc="Geocodificando ubicaciones"):
        
        # Intentar con el nombre completo
        location_data = geolocator.geocode(location_name)
    
        # Si falla, intentar simplificar el nombre
        if location_data is None:
            parts = [p.strip() for p in location_name.split(',')]
            
            if len(parts) > 2:
                simplified_location = ', '.join(parts[1:]) # Quitar la primera parte, nombre específico del estadio
                tqdm.write(f"'{location_name}' no encontrado. \nIntentando fallback: '{simplified_location}'")
                
                # Intentar con el nombre simplificado
                location_data = geolocator.geocode(simplified_location)
    
        # Guardar resultados en caché (tupla lat/lon o None/None)
        if location_data:
            coordenadas_cache[location_name] = (location_data.latitude, location_data.longitude)
        else:
            print(f"Ubicación '{location_name}' no encontrada.")
            coordenadas_cache[location_name] = (None, None)
        # Respetar la política de uso del servicio
        time.sleep(1)
    
    # Aplicar las coordenadas al DataFrame    
    coords_list = df['location'].str.strip().map(
        lambda loc: coordenadas_cache.get(loc, (None, None))
    )
    # Separar en columnas de latitud y longitud     
    df['latitud'] = coords_list.apply(lambda x: x[0])
    df['longitud'] = coords_list.apply(lambda x: x[1])
    
    # Guardar resultados
    print(f"Guardando los resultados en {output_csv_path}")
    df.to_csv(output_csv_path, index=False, encoding='utf-8-sig')
    
    print("\n¡Proceso completado con éxito!")
    
    # Resumen de resultados    
    
    no_encontrados = df['latitud'].isna().sum()
    encontrados = len(df) - no_encontrados
    print(f"Resumen: \nSe procesaron {len(df)} eventos.")
    print(f"Coordenadas encontradas para {encontrados} eventos.")
    print(f"No se encontraron coordenadas para {no_encontrados} eventos.")