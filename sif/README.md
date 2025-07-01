Bootstrap: docker
From: ubuntu:22.04 # Or ubuntu:20.04 if you prefer an older LTS base

%post
    export DEBIAN_FRONTEND=noninteractive
    export TZ=Etc/UTC
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

    # CRUCIAL: run apt-get update BEFORE installing packages
    apt-get update -y
    # apt-get upgrade -y # Upgrading is optional and can sometimes take a long time. Updating is essential.

    echo "APT repositories updated. Attempting to install packages..."

    apt-get install -y --no-install-recommends \
        build-essential \
        wget \
        ca-certificates \
        bzip2 \
        unzip \
        git \
        ffmpeg \
        libx11-6 \
        libxext6 \
        libxau6 \
        libxdmcp6 \
        libgl1-mesa-glx \
        libgl1-mesa-dri \
        libglu1-mesa \
        xvfb
    
    echo "System packages installation complete."

    # Clean up the apt cache
    apt-get clean
    rm -rf /var/lib/apt/lists/*

    # Install Miniforge
    UNAME_S=$(uname -s)
    UNAME_M=$(uname -m)
    MINIFORGE_FILENAME="Miniforge3-${UNAME_S}-${UNAME_M}.sh"
    
    echo "Downloading Miniforge: ${MINIFORGE_FILENAME}"
    wget "https://github.com/conda-forge/miniforge/releases/latest/download/${MINIFORGE_FILENAME}" -O miniforge.sh
    
    /bin/bash miniforge.sh -b -p /opt/conda
    rm miniforge.sh
    
    . /opt/conda/etc/profile.d/conda.sh
    conda activate base

    conda update -n base -c defaults conda -y
    # Ensure /opt/environment.yml is created by the %files section
    conda env create -f /opt/environment.yml 

    conda clean -afy

    # Activate the created environment for testing (optional here)
    # conda activate pyvista_env_from_yml # Replace with the environment name from your YML file

%files
    # Copy your environment.yml file to the /opt directory inside the container
    # Ensure 'my_environment.yml' is in the same directory as the .def file during the build
    my_environment.yml /opt/environment.yml

    # (Optional) Copy your main Python script into the container
    # your_main_script.py /app/your_main_script.py
    # texture.jpg /app/texture.jpg

%environment
    # Export the necessary environment variables for the Conda environment
    export CONDA_PREFIX="/opt/conda"
    # Replace 'pyvista_env_from_yml' with the exact name of your environment
    # specified in the environment.yml file (the 'name:' field)
    export CONDA_ENV_NAME="pyvista_cpu_lumi" # Use the name from your YML file
    export PATH="$CONDA_PREFIX/envs/$CONDA_ENV_NAME/bin:$CONDA_PREFIX/bin:$PATH"
    export LD_LIBRARY_PATH="$CONDA_PREFIX/envs/$CONDA_ENV_NAME/lib:$LD_LIBRARY_PATH"

    # Variables for headless rendering with VTK/PyVista
    export PYVISTA_OFF_SCREEN="true"
    export DISPLAY=""
    export MPLBACKEND="Agg" # For Matplotlib, if used

    # Sometimes, forcing software rendering with Mesa can help with virtual hardware issues
    # export LIBGL_ALWAYS_SOFTWARE=true

%runscript
    # This command is executed when you run `singularity run my_container.sif <args>`
    # The Conda environment should be implicitly activated by the environment variables
    # or you can activate it explicitly here if needed (though PATH/LD_LIBRARY_PATH should suffice).
    
    # If you copied your script into the container at /app/:
    # exec python /app/your_main_script.py "$@"

    # If the script is mounted from the host instead:
    echo "Container is running. The $CONDA_ENV_NAME environment should be active."
    echo "Use 'singularity exec my_container.sif python /path/to/host_script.py <args>'"
    # Execute a default command or show a help message
    exec python "$@" # This allows passing the script and its arguments directly
                     # Example: singularity run my_container.sif /host/path/script.py --arg1


%labels
    Author MdMV
    Version 1.0-custom-build
