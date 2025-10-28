import csv

def convert_height_to_cm(height_str):
    """Converts height from 'feet\'inches"' format to centimeters."""
    try:
        # Handles formats like "5'10\""
        feet_str, inches_str = height_str.replace('"', '').split("'")
        feet = int(feet_str)
        inches = int(inches_str)
        total_inches = (feet * 12) + inches
        # 1 inch = 2.54 cm
        return round(total_inches * 2.54, 2)
    except (ValueError, AttributeError):
        # Return the original value or None if conversion fails
        return height_str

def convert_weight_to_kg(weight_str):
    """Converts weight from 'lbs' format to kilograms."""
    try:
        # Handles formats like "155 lbs"
        pounds = float(weight_str.lower().replace('lbs', '').strip())
        # 1 pound = 0.453592 kg
        return round(pounds * 0.453592, 2)
    except (ValueError, AttributeError):
        # Return the original value or None if conversion fails
        return weight_str

# Define the input and output filenames
input_filename = 'pro_mma_fighters.csv'
output_filename = 'pro_mma_fighters_cocinados.csv'

try:
    # Open the input file for reading and the output file for writing
    with open(input_filename, mode='r', newline='', encoding='utf-8') as infile, \
         open(output_filename, mode='w', newline='', encoding='utf-8') as outfile:

        reader = csv.reader(infile)
        writer = csv.writer(outfile)

        # Read the header row from the input file
        header = next(reader)

        # Find the indices for height and weight columns
        try:
            height_index = header.index('height')
            weight_index = header.index('weight')
        except ValueError as e:
            print(f"Error: Missing required column in the CSV file: {e}")
            exit()

        # Modify the header for the output file
        header[height_index] = 'height_cm'
        header[weight_index] = 'weight_kg'
        writer.writerow(header)

        # Process each row in the input file
        for row in reader:
            # Check if the row has enough columns before processing
            if len(row) > max(height_index, weight_index):
                # Convert height and weight using the functions
                row[height_index] = convert_height_to_cm(row[height_index])
                row[weight_index] = convert_weight_to_kg(row[weight_index])
            
            # Write the transformed row to the output file
            writer.writerow(row)

    print(f"Successfully processed the file.")
    print(f"Transformed data has been saved to '{output_filename}'")

except FileNotFoundError:
    print(f"Error: The file '{input_filename}' was not found.")
    print("Please make sure the file is in the same directory as the script.")
