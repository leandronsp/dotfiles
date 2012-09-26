#!/bin/bash
#
# This is a tool to manage dotfiles in home directory
#

SCRIPT_DIR="${HOME}/.dotfiles"


function install() {
    for FILE in $(ls ${SCRIPT_DIR})
    do
        echo -n "${SCRIPT_DIR}/${FILE}: "
        if [ -e "${HOME}/.${FILE}" ]; then
            echo "${HOME}/.${FILE} already exists, skipping."
        else
            if ln -s "${SCRIPT_DIR}/${FILE}" "${HOME}/.${FILE}"; then
                echo "linked to ${HOME}/.${FILE}"
            fi
        fi
    done
}

install
