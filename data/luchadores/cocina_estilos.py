import pandas as pd
import random

if __name__ == "__main__":
    
    # Define los nombres de archivos de entrada y salida
    input_filename = 'data/luchadores/pro_mma_fighters.csv'
    output_filename_estilos = 'data/luchadores/estilos.csv'
    output_filename_estilos_luchadores = 'data/luchadores/estilos-luchadores.csv'
    estilos_txt = 'data/luchadores/estilos.txt'
    
    # Lee y procesa los estilos únicos desde el archivo de texto
    # definimos encoding utf-8 para evitar problemas
    estilos = []
    with open(estilos_txt, 'r', encoding='utf-8') as file:
        content = file.read()
        for estilo in content.split(','):
            estilo = estilo.strip().lower()
            if estilo and estilo not in estilos:
                estilos.append(estilo)
    
    # Crea DataFrame de estilos con IDs
    estilos_df = pd.DataFrame({
        'id': range(1, len(estilos) + 1),
        'nombre': estilos
    })
    estilos_df.to_csv(output_filename_estilos, index=False)
    
    # Lee los datos de luchadores
    fighters_df = pd.read_csv(input_filename)
    
    # Crea asignaciones aleatorias de estilos para cada luchador
    estilo_luchador = []
    for fighter_id in fighters_df['url']:
        # Decide aleatoriamente cuántos estilos (0 a 3) tiene cada luchador
        num_styles = random.randint(0, 3)
        if num_styles > 0:
            # Selecciona aleatoriamente los estilos para este luchador
            selected_styles = random.sample(range(1, len(estilos) + 1), num_styles)
            for style_id in selected_styles:
                estilo_luchador.append({
                    'luchador_id': fighter_id,
                    'estilo_id': style_id
                })
    
    # Crea y guarda el DataFrame de relación
    estilo_luchador_df = pd.DataFrame(estilo_luchador)
    estilo_luchador_df.to_csv(output_filename_estilos_luchadores, index=False)