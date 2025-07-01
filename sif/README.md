# Building the Singularity Container

This directory contains the necessary files to build a Singularity container equipped with a Conda environment for PyVista.

## Prerequisites

Before you begin, ensure you have the following:

1.  **Singularity (or Apptainer)**: You must have Singularity (version 3.x+) or its successor, Apptainer, installed on your system.
2.  **Sudo Privileges**: The build process requires administrator (`sudo`) permissions to create the container image from a definition file.

## Files in This Directory

*   `pyvista_lumi_custom_EN.def`: The main Singularity definition file. This is the "recipe" that orchestrates the entire build process.
*   `my_environment.yml`: The Conda environment specification. It lists all the Python packages and their versions to be installed inside the container.

## Build Instructions

Follow these steps to build the container image.

1.  **Open a terminal**.

2.  **Navigate to this directory** (the `sif` folder where this README is located).
    ```bash
    cd /path/to/your/sif
    ```

3.  **Run the build command**. This will read the definition file, execute all the steps, and create a single, portable Singularity Image File (`.sif`).

    **For Singularity:**
    ```bash
    sudo singularity build pyvista_cpu.sif pyvista_lumi_custom_EN.def
    ```

    **For Apptainer:**
    ```bash
    sudo apptainer build pyvista_cpu.sif pyvista_lumi_custom_EN.def
    ```

> **Note:** You can replace `pyvista_cpu.sif` with any name you prefer for the final container file.

## After the Build

The build process may take several minutes as it downloads the base OS, installs system packages, sets up Conda, and resolves the Python environment.

Once it completes successfully, a new file named `pyvista_cpu.sif` (or the name you chose) will appear in this directory. This `.sif` file is your self-contained, reproducible, and portable scientific environment.

---

## Alternative: Building without `sudo` (Remote Build)

If you are on a system where you do not have `sudo` privileges (e.g., an HPC login node), you may be able to use a remote builder. Sylabs offers a free remote build service for public repositories.

1.  **Create a Sylabs Cloud account** and configure it on your machine:
    ```bash
    singularity remote login
    ```

2.  **Run the build command with the `--remote` flag**:
    ```bash
    singularity build --remote pyvista_cpu.sif pyvista_lumi_custom_EN.def
    ```
This will upload your definition file, build it on Sylabs' servers, and download the finished `.sif` image to your current directory.
