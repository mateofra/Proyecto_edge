import pandas as pd
import os

if __name__ == "__main__":
    
    # Los nombres de los archivos de entrada y salida
    
    archivo_entrada = 'data/luchas/pro_mma_fights.csv'
    archivo_salida_eventos = 'data/luchas/events.csv'
    archivo_salida_peleas = 'data/luchas/fights.csv'
    
    # Verifica si el archivo de entrada existe
    
    if not os.path.exists(archivo_entrada):
        print(f"Error: El archivo de entrada '{archivo_entrada}' no fue encontrado.")
    else:
        # Carga el archivo CSV completo en un DataFrame de pandas
        df = pd.read_csv(archivo_entrada)

        ##### Evento
        # Selecciona las columnas 
        evento_columnas = [
            'url',
            'event_title',
            'organisation',
            'date',
            'location']

        # El eliminar las filas duplicadas permite obtener una tabla de eventos única
        events_df = df[evento_columnas].drop_duplicates().copy()

        # Reordena las columnas para que 'event_id' sea la primera
        events_df = events_df[['url', 'event_title', 'organisation', 'date', 'location']]

        ##### Pelea

        # Copia el DataFrame original para la tabla de peleas
        fights_df = df.copy()

        # Selecciona y reordena las columnas para la tabla de peleas final
        fight_columns = [
            'url',
            'match_nr',
            'fighter1_url',
            'fighter2_url',
            'fighter1_result',  # Esta columna será renombrada a 'results'.
            'win_method',
            'win_details',
            'referee',
            'round',
            'time'
        ]
        fights_df = fights_df[fight_columns]

        # Renombrar 'fighter1_result' a 'results' y eliminar 'fighter2_result'
        # Ademas, renombrar 'url' a 'event_id'
        fights_df.rename(columns={'fighter1_result': 'results'}, inplace=True)
        fights_df.rename(columns={'url': 'event_id'}, inplace=True)

        # Guarda los dos DataFrames en sus respectivos archivos CSV sin el índice de pandas
        events_df.to_csv(archivo_salida_eventos, index=False, encoding='utf-8')
        fights_df.to_csv(archivo_salida_peleas, index=False, encoding='utf-8')

        print(f"Proceso completado con éxito!")
        print(f"Se ha creado el archivo de eventos: '{archivo_salida_eventos}'")
        print(f"Se ha creado el archivo de peleas: '{archivo_salida_peleas}'")
