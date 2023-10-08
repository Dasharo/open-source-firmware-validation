import re


def extract_label_from_entry(input_string):
    # Split the input string by ","
    parts = input_string.split(",")

    # Remove leading ">" from the first part and strip any whitespaces
    extracted_text = parts[0].strip().lstrip(">").strip()

    return extracted_text


def get_file_explorer_volumes(terminal_output):
    # Get lines starting with >
    lines = re.findall(r"^\s>\s.*$", terminal_output, re.MULTILINE)

    volume_labels = []

    for entry in lines:
        # Extract the text using the custom function
        extracted_text = extract_label_from_entry(entry)
        volume_labels.append(extracted_text)

    return volume_labels
