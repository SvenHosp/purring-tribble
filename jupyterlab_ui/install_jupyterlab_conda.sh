#!/bin/bash

TRIBBLE_CONDA_ENV_NAME=jubilant_tribble_jupyterlab

read -p "Please enter the installation directory path for tribble jupyter ui [~/tribble_ui]:" USER_INPUT_INSTALL_DIRECTORY
JUBILANT_TRIBBLE_HOME_UI=${USER_INPUT_INSTALL_DIRECTORY:-~/tribble_ui}

# https://stackoverflow.com/questions/70597896/check-if-conda-env-exists-and-create-if-not-in-bash
find_in_conda_env(){
   conda env list | grep "${@}" >/dev/null 2>/dev/null
}

if [ ! -z $JUBILANT_TRIBBLE_HOME ]; then

    BACKUP_NAME="backup_$(date +"%Y%m%d%H%M%S")"

    echo "Now, I add the path to the scripts to your local .zshrc. Before I do this do a backup of your config: .zshrc_$BACKUP_NAME"

    cp ~/.zshrc ~/.zshrc_$BACKUP_NAME

    if find_in_conda_env "$TRIBBLE_CONDA_ENV_NAME" ; then
        echo "The conda env exists. I only run pip install to update your library."
        conda run -n $TRIBBLE_CONDA_ENV_NAME pip install -r requirements.txt
    else
        echo "The conda env $TRIBBLE_CONDA_ENV_NAME doesn't exist. I'll create it."
        echo "I add the name of the jupyter conda env to  .zshrc."
        ! grep "export TRIBBLE_CONDA_ENV_NAME=$TRIBBLE_CONDA_ENV_NAME" ~/.zshrc && echo "export TRIBBLE_CONDA_ENV_NAME=$TRIBBLE_CONDA_ENV_NAME" >> ~/.zshrc
        conda create -n $TRIBBLE_CONDA_ENV_NAME python=3.11 pip
        conda run -n $TRIBBLE_CONDA_ENV_NAME pip install  -r requirements.txt
    fi

    ! grep "export JUBILANT_TRIBBLE_HOME_UI=" ~/.zshrc && echo "export JUBILANT_TRIBBLE_HOME_UI=$JUBILANT_TRIBBLE_HOME_UI" >> ~/.zshrc

    ! grep "alias tribble_ui=" ~/.zshrc && echo 'alias tribble_ui="$JUBILANT_TRIBBLE_HOME/start_tribble_ui.sh"' >> ~/.zshrc

    echo "Begin copying scripts to JUBILANT_TRIBBLE_HOME."
    cp start_tribble_ui.sh $JUBILANT_TRIBBLE_HOME
    
    mkdir -p $JUBILANT_TRIBBLE_HOME/workspaces
    cp workspaces/* $JUBILANT_TRIBBLE_HOME/workspaces/

    sed -i "" "s|<TRIBBLE_MAIN_PATH>|$JUBILANT_TRIBBLE_HOME_UI|g" ${JUBILANT_TRIBBLE_HOME}/workspaces/tribble.json

    cp tribble_status.ipynb $JUBILANT_TRIBBLE_HOME
    cp tribble.ipynb $JUBILANT_TRIBBLE_HOME

else
    echo "Environment Variable JUBILANT_TRIBBLE_HOME is not set. Please install juilant tribble before!"
fi
