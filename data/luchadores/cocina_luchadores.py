import csv

def convert_height_to_cm(height_str):
    """Convierte la altura del formato 'pies\'pulgadas"' a centímetros."""
    try:
        # Maneja formatos como "5'10\""
        feet_str, inches_str = height_str.replace('"', '').split("'")
        feet = int(feet_str)
        inches = int(inches_str)
        total_inches = (feet * 12) + inches
        # 1 pulgada = 2.54 cm
        return round(total_inches * 2.54, 2)
    except (ValueError, AttributeError):
        # Devuelve el valor original o None si la conversión falla
        return height_str

def convert_weight_to_kg(weight_str):
    """Convierte el peso del formato 'lbs' a kilogramos."""
    try:
        # Maneja formatos como "155 lbs"
        pounds = float(weight_str.lower().replace('lbs', '').strip())
        # 1 libra = 0.453592 kg
        return round(pounds * 0.453592, 2)
    except (ValueError, AttributeError):
        # Devuelve el valor original o None si la conversión falla
        return weight_str

# --- MODIFICACIÓN: Define aquí las columnas que quieres guardar ---
# Asegúrate de que los nombres coincidan exactamente con los de la cabecera del CSV original.
columnas_deseadas = [
    'url', 'fighter_name', 'nickname', 'birth_date', 'age', 'country', 
    'height', 'weight', 'association', 'weight_class', 'wins', 'lossess'
]

# Define los nombres de los archivos de entrada y salida
input_filename = 'data/luchadores/pro_mma_fighters.csv'
output_filename = 'data/luchadores/pro_mma_fighters_cocinados.csv'

try:
    # Abre el archivo de entrada para leer y el de salida para escribir
    with open(input_filename, mode='r', newline='', encoding='utf-8') as infile, \
         open(output_filename, mode='w', newline='', encoding='utf-8') as outfile:

        reader = csv.reader(infile)
        writer = csv.writer(outfile)

        # Lee la fila de la cabecera del archivo de entrada
        header = next(reader)

        # --- MODIFICACIÓN: Encuentra los índices de las columnas que queremos conservar ---
        try:
            indices_deseados = [header.index(col) for col in columnas_deseadas]
            # Encuentra los índices específicos para altura y peso para la conversión
            height_index = header.index('height')
            weight_index = header.index('weight')
        except ValueError as e:
            print(f"Error: La columna requerida no se encuentra en el archivo CSV: {e}")
            exit()

        # --- MODIFICACIÓN: Crea la nueva cabecera solo con las columnas deseadas ---
        # y renombra las columnas de altura y peso
        output_header = list(columnas_deseadas)
        height_output_idx = output_header.index('height')
        weight_output_idx = output_header.index('weight')
        output_header[height_output_idx] = 'height_cm'
        output_header[weight_output_idx] = 'weight_kg'
        writer.writerow(output_header)

        # Procesa cada fila en el archivo de entrada
        for row in reader:
            # --- MODIFICACIÓN: Crea una nueva fila solo con los datos de las columnas deseadas ---
            output_row = []
            for index in indices_deseados:
                # Asegúrate de que la fila tenga suficientes columnas
                if index < len(row):
                    output_row.append(row[index])
                else:
                    output_row.append(None) # Añade None si la fila es más corta de lo esperado

            # Convierte altura y peso en la nueva fila
            if output_row: # Procesa solo si la fila no está vacía
                output_row[height_output_idx] = convert_height_to_cm(output_row[height_output_idx])
                output_row[weight_output_idx] = convert_weight_to_kg(output_row[weight_output_idx])
            
            # Escribe la fila transformada (y filtrada) en el archivo de salida
            writer.writerow(output_row)

    print(f"Proceso completado con éxito.")
    print(f"Los datos transformados se han guardado en '{output_filename}'")

except FileNotFoundError:
    print(f"Error: No se encontró el archivo '{input_filename}'.")
