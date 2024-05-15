from robot.api.deco import keyword


@keyword("Convert Mokutil To Openssl Output")
def convert_mokutil_to_openssl_output(file_content):
    """
    Converts mokutil output to openssl output. Returns the modified file
    content.
    """
    lines = file_content.split("\n")
    modified_content = ""
    for line in lines:
        if line.startswith("SHA1 Fingerprint"):
            # Extract the fingerprint part, work on whitespaces and skip adding
            # this line to modified content
            continue
        elif line.startswith("[key 1]"):
            continue
        if line == lines[-1]:
            modified_content += line
        else:
            # Add other lines to modified content and remove whitespaces around
            # the '=' char
            line = line.replace("=", " = ")
            modified_content += line + "\n"
    # Append the fingerprint to the end
    return modified_content
