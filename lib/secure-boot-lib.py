from robot.api.deco import keyword  

def move_sha1_fingerprint_and_get_content(file_content, line_start, delimiter):
    """
    Removes the line containing the SHA1 fingerprint from file content.
    Returns the modified file content.
    """
    lines = file_content.split('\n')
    fingerprint = None
    modified_content = ""
    for line in lines:
        if line.startswith(line_start) and not fingerprint:
            # Extract the fingerprint part, change it to uppercase and skip adding this line to modified content
            fingerprint = line.split(delimiter, 1)[-1].strip().upper()
            # fingerprint = line.replace("=", ":").upper()
        elif line.startswith('[key 1]'):
            continue
        else:
            # Add other lines to modified content and remove whitespaces around
            # the '=' char
            line = line.replace(' = ', '=')
            modified_content += line + '\n'
    # Append the fingerprint to the end
    modified_content += fingerprint
    return modified_content

@keyword ('Compare Mokutil And OpenSSL Outputs')
def compare_mokutil_and_openssl_outputs(mokutil_file, openssl_file):
    """
    Modifies the outputs from mokutil and openssl-x509 to have the same format and
    compares them. Requires the openssl file to be created with openssl x509 -in
    <file> -noout -text -fingerprint > filename.
    """
    mokutil_content = \
    move_sha1_fingerprint_and_get_content(mokutil_file, 'SHA1 Fingerprint', ':')

    openssl_content = \
    move_sha1_fingerprint_and_get_content(openssl_file, 'SHA1 Fingerprint', "=")

    # Compare contents
    if mokutil_content and openssl_content:
        if mokutil_content == openssl_content:
            return True
    return False
