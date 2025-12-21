import csv
import pandas as pd

def pies_pulgadas_a_cm(height_str):
    try:
        # Maneja formatos "5'10\""
        pies, pulgadas = height_str.replace('"', '').split("'")
        pies = int(pies)
        pulgadas = int(pulgadas)
        total = (pies * 12) + pulgadas
        # 1 pulgada = 2.54 cm
        return round(total * 2.54, 2)
    except (ValueError, AttributeError):
        # Devuelve el valor original o None si la conversión falla
        return height_str

def libras_a_kgs(weight_str):
    try:
        # Maneja formatos "155 lbs"
        pounds = float(weight_str.lower().replace('lbs', '').strip())
        # 1 libra = 0.453592 kg
        return round(pounds * 0.453592, 2)
    except (ValueError, AttributeError):
        # Devuelve el valor original o None si la conversión falla
        return weight_str
    
if __name__ == "__main__":
    # columnas que queremos conservar en el archivo de salida
    columnas = [
        'url', 'fighter_name', 'nickname', 'birth_date', 'age', 'country', 
        'height', 'weight', 'association', 'weight_class', 'wins', 'lossess'
    ]

    # Define los nombres de los archivos de entrada y salida
    input_filename = 'data/luchadores/pro_mma_fighters.csv'
    output_filename = 'data/luchadores/pro_mma_fighters_cocinados.csv'

    try:
        # Lee el archivo CSV con pandas
        df = pd.read_csv(input_filename, encoding='utf-8')
        
        # Selecciona solo las columnas deseadas
        df = df[columnas]
        
        # Renombra las columnas
        df = df.rename(columns={
            'height': 'height_cm',
            'weight': 'weight_kg',
            'lossess': 'losses'
        })
        
        # Aplica las conversiones
        df['height_cm'] = df['height_cm'].apply(pies_pulgadas_a_cm)
        df['weight_kg'] = df['weight_kg'].apply(libras_a_kgs)
        
        # Encuentra luchadores sin nombre
        missing_names = df[df['fighter_name'].isna()]
        print(f"Número de luchadores sin nombre: {len(missing_names)}")

        # Extrae el nombre del URL y reemplaza los valores faltantes
        def extraer_nombre_del_url(url):
            if pd.isna(url):
                return None
            # Extrae la parte entre /fighter/ y el último guion seguido de números
            try:
                nombre = url.split('/fighter/')[-1].rsplit('-', 1)[0].replace('-', ' ')
                print( f"Extraído nombre del URL '{url}': '{nombre.title()}'" )
                return nombre.title()
            except:
                return None

        df.loc[df['fighter_name'].isna(), 'fighter_name'] = df.loc[df['fighter_name'].isna(), 'url'].apply(extraer_nombre_del_url)
        
        
        
        # Guarda el archivo transformado
        df.to_csv(output_filename, index=False, encoding='utf-8')
        
        print(f"Proceso completado con éxito.")
        print(f"Los datos transformados se han guardado en '{output_filename}'")

    except FileNotFoundError:
        print(f"Error: No se encontró el archivo '{input_filename}'.")
