*** Variables ***
${CURRENT_DATE}    # Date of starting of the test. Format: %d%m%Y%H%M%S
${results_path_root}=    Set Variable    /var/lib/phoronix-test-suite/test-results
${deviation_up}=    1.2    # confirm with the client
${deviation_down}=    0.8

# # Novacustom V540TU 155 H

# ${HD_RENDER}=        96.520       # seconds
# ${4K_RENDER}=        387.391        # seconds
# ${5K_RENDER}=        695.825        # seconds
# ${COREMARK}=                # interations/s
# ${7ZIP_COMP}=        65965        # MIMPS
# ${7ZIP_DECOMP}=      42238        # MIMPS

# Novacustom V540TU 125 H
${HD_RENDER}=        105.8        # seconds
${4K_RENDER}=        426.2        # seconds
${5K_RENDER}=        766.4        # seconds
${COREMARK}=         348400.3        # interations/s
${7ZIP_COMP}=        60263        # MIMPS
${7ZIP_DECOMP}=      35772        # MIMPS

# # Novacustom V540TND
# ${HD_RENDER}=        90.8        # seconds
# ${4K_RENDER}=        356.9        # seconds
# ${5K_RENDER}=        654.5        # seconds
# ${COREMARK}=         400079.5        # interations/s
# ${7ZIP_COMP}=        63476        # MIMPS
# ${7ZIP_DECOMP}=      39336        # MIMPS
