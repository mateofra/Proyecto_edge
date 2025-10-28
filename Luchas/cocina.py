import pandas as pd
import os

# Define los nombres de los archivos de entrada y salida
input_filename = 'pro_mma_fights.csv'
events_output_filename = 'events.csv'
fights_output_filename = 'fights.csv'

# Verifica si el archivo de entrada existe
if not os.path.exists(input_filename):
    print(f"Error: El archivo de entrada '{input_filename}' no fue encontrado.")
    print("Por favor, asegúrate de que el archivo esté en el mismo directorio que el script.")
else:
    # Carga el archivo CSV completo en un DataFrame de pandas
    df = pd.read_csv(input_filename)

    # --- 1. Creación de la tabla de eventos ---

    # Selecciona las columnas que definen un evento de manera única
    event_columns = ['url', 'event_title', 'organisation', 'date', 'location']
    
    # Crea el DataFrame de eventos eliminando las filas duplicadas
    events_df = df[event_columns].drop_duplicates().copy()

    # Crea un 'event_id' único para cada evento. 
    # Usamos el índice reseteado como un ID simple y numérico.
    events_df.reset_index(drop=True, inplace=True)
    events_df['event_id'] = events_df.index

    # Reordena las columnas para que 'event_id' sea la primera
    events_df = events_df[['event_id', 'url', 'event_title', 'organisation', 'date', 'location']]

    # --- 2. Creación de la tabla de peleas ---

    # Para asignar el 'event_id' correcto a cada pelea, fusionamos el DataFrame original
    # con nuestro nuevo DataFrame de eventos. La columna 'url' del evento actúa como clave.
    fights_df = pd.merge(df, events_df[['url', 'event_id']], on='url', how='left')

    # Selecciona y reordena las columnas para la tabla de peleas final
    fight_columns = [
        'event_id',
        'match_nr',
        'fighter1_url',
        'fighter1_name',
        'fighter2_url',
        'fighter2_name',
        'fighter1_result',
        'fighter2_result',
        'win_method',
        'win_details',
        'referee',
        'round',
        'time'
    ]
    fights_df = fights_df[fight_columns]

    # --- 3. Guardar los DataFrames en archivos CSV ---

    # Guarda los dos DataFrames en sus respectivos archivos CSV sin el índice de pandas
    events_df.to_csv(events_output_filename, index=False, encoding='utf-8')
    fights_df.to_csv(fights_output_filename, index=False, encoding='utf-8')

    print(f"¡Proceso completado con éxito!")
    print(f"Se ha creado el archivo de eventos: '{events_output_filename}'")
    print(f"Se ha creado el archivo de peleas: '{fights_output_filename}'")
