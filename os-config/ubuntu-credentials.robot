*** Variables ***
# TODO: we still cannot have stable username/password/hostname
# across installations. At least hostname has been defined, and
# username and hostname variables are used in the prompts. Before,
# we needed to change them in prompts as well.
${UBUNTU_USERNAME}=         ubuntu
${UBUNTU_PASSWORD}=         ubuntu
${UBUNTU_HOSTNAME}=         3mdeb

${UBUNTU_USER_PROMPT}=      ${UBUNTU_USERNAME}@${UBUNTU_HOSTNAME}:~$
${UBUNTU_ROOT_PROMPT}=      root@${UBUNTU_HOSTNAME}:/home/${UBUNTU_USERNAME}#
