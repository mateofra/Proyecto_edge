import pandas as pd
import random

# Define the input and output filenames
input_filename = 'data/luchadores/pro_mma_fighters.csv'
output_filename_estilos = 'data/luchadores/estilos.csv'
output_filename_estilos_luchadores = 'data/luchadores/estilos-luchadores.csv'

estilos = ['jiu-jitsu','wrestling','kickboxing','boxing','judo','karate','sambo','taekwondo']

# Create estilos DataFrame with IDs
estilos_df = pd.DataFrame({
    'id': range(1, len(estilos) + 1),
    'nombre': estilos
})
estilos_df.to_csv(output_filename_estilos, index=False)

# Read fighters data
fighters_df = pd.read_csv(input_filename)

# Create random style assignments for each fighter
estilo_luchador = []
for fighter_id in fighters_df['url']:
    # Randomly decide how many styles (0 to 3) each fighter has
    num_styles = random.randint(0, 3)
    if num_styles > 0:
        # Randomly select styles for this fighter
        selected_styles = random.sample(range(1, len(estilos) + 1), num_styles)
        for style_id in selected_styles:
            estilo_luchador.append({
                'luchador_id': fighter_id,
                'estilo_id': style_id
            })

# Create and save the relationship DataFrame
estilo_luchador_df = pd.DataFrame(estilo_luchador)
estilo_luchador_df.to_csv(output_filename_estilos_luchadores, index=False)