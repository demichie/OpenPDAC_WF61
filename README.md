# OpenPDAC Simulation Workflow on LUMI

This guide provides comprehensive instructions for compiling, configuring, and running the OpenPDAC simulation workflow on the LUMI supercomputer.

The workflow relies on a combination of three key components:
1.  **Custom-compiled C++ solvers** (OpenPDAC and its utilities).
2.  A **Conda environment** for standard Python-based post-processing.
3.  A **Singularity container** for advanced 3D visualization with complex dependencies.

---

## ✅ 1. Installation & Setup (One-Time Process)

Before running any simulations, you must set up your software environment. This is a **one-time process**.

### Step 1.1: Compile OpenPDAC & Utilities

First, download and compile the core C++ software.

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/demichie/OpenPDAC-12.git
    ```

2.  **Load the OpenFOAM Environment**: The compilation depends on OpenFOAM-12. Load the necessary modules. It's recommended to add these lines to your `~/.bashrc` file.
    ```bash
    module use /appl/local/csc/modulefiles
    module load openfoam/12
    ```

3.  **Compile `topoGrid` Utility**:
    ```bash
    cd OpenPDAC-12/utilities/topoGrid
    wmake
    cd ../.. # Return to OpenPDAC-12 root
    ```
    The compiled binary will be located in `$FOAM_USER_APPBIN`.

4.  **Compile `OpenPDAC` Solver**:
    ```bash
    cd applications/OpenPDAC
    ./Allwmake
    # Return to your main case directory when done
    cd ../..
    ```
    The compiled libraries will be located in `$FOAM_USER_LIBBIN`.

### Step 1.2: Build the Singularity Container

The final post-processing step (`plotIso.py`) requires a Singularity container for its complex Python dependencies.

1.  **Navigate to the `sif` directory**:
    ```bash
    cd sif
    ```
2.  **Follow the build instructions**: Inside this directory, there is a separate `README.md` file. Follow its instructions to build the container. This will typically involve a command like:
    ```bash
    # This is an example, check sif/README.md for the exact command
    sudo singularity build pyvista_lumi_custom_container.sif your_definition_file.def
    ```
3.  **Move the container to the main directory**: After the build is complete, a `pyvista_lumi_custom_container.sif` file will be created. Move it to the parent case directory.
    ```bash
    mv pyvista_lumi_custom_container.sif ..
    ```
4.  **Return to the main directory**:
    ```bash
    cd ..
    ```

### Step 1.3: Create the Python Conda Environment

The workflow uses several other Python scripts whose dependencies are managed via a Conda environment.

1.  **Ensure you are in your main case directory**, where the `environment.yml` file is located.
2.  **Run `conda-containerize`**: This command creates a self-contained Conda environment in a new directory named `OpenPDACconda`.
    ```bash
    conda-containerize new --prefix OpenPDACconda environment.yml
    ```

---

## ⚙️ 2. Workflow Configuration

Now, configure your case scripts to use the environments you just created.

### Step 2.1: Configure the Conda Environment Path

**➡️ Action:** Open the scripts that use Python (`Allrun.pre-1`, `Allrun.post-1`) and ensure the `PATH` variable points to the **absolute path** of your `OpenPDACconda` directory.

*   **Find and update this line:**
    ```bash
    # Update this line in Allrun.pre-1, Allrun.post-1, etc.
    export PATH="/users/YOUR_USERNAME/path/to/case/OpenPDACconda/bin:$PATH"
    ```

### Step 2.2: Configure the Singularity Container Path

**➡️ Action:** Open `Allrun.post-2` and ensure the `SIF_PATH` variable points to the **absolute path** of your `.sif` file.

*   **Find and update this line:**
    ```bash
    # Update this line in Allrun.post-2
    SIF_PATH="/users/YOUR_USERNAME/path/to/case/pyvista_lumi_custom_container.sif"
    ```

---

## 🚀 3. Running the Simulation

Submit the workflow stages sequentially. **Wait for each job to complete before submitting the next.**

1.  **`sbatch ncores-pre-1.sh`**
2.  **`sbatch ncores-pre-2.sh`**
3.  **`sbatch ncores-run.sh`**
4.  **`sbatch ncores-post-1.sh`**
5.  **`sbatch ncores-post-2.sh`**

---

## 🔬 4. Workflow Stages Explained

Each script corresponds to a logical stage and uses a specific software environment.

### Stages 1 & 2: Preprocessing (`ncores-pre-1.sh`, `ncores-pre-2.sh`)
*   **Environment**: **Compiled OpenFOAM/OpenPDAC tools**.
*   **Description**: Creates and refines the mesh, and initializes the physical fields.

### Stage 3: Main Simulation (`ncores-run.sh`)
*   **Environment**: **Compiled OpenPDAC solver**.
*   **Description**: Runs the core 3D multiphase flow simulation.

### Stage 4: Post-Processing 1 (`ncores-post-1.sh`)
*   **Environment**: **`OpenPDACconda` Conda environment**.
*   **Description**: Generates 2D hazard maps and ballistic trajectory plots.

### Stage 5: Post-Processing 2 (`ncores-post-2.sh`)
*   **Environment**: **`pyvista_lumi_custom_container.sif` Singularity container**.
*   **Description**: Creates 3D visualizations (isosurfaces) and renders them into MP4 video files.

---

## 🔎 5. Monitoring and Troubleshooting

*   **Job Status**: Use `squeue -u YOUR_USERNAME` to monitor job progress.
*   **Logs**: Check `slurm-*.out` and `log.*` files for output and errors.
*   **Compilation Errors**: If `wmake` or `./Allwmake` fail, ensure the OpenFOAM modules are loaded (`module list`).
*   **Container Build Errors**: If the Singularity build fails, check the `sif/README.md` and the error messages in your terminal. You may need `sudo` privileges.
*   **Python/Conda Errors**: If `ncores-post-1.sh` fails (e.g., `ModuleNotFoundError`), verify that the `PATH` in its `Allrun` script correctly points to your `OpenPDACconda/bin` directory.
*   **Container Execution Errors**: If `ncores-post-2.sh` fails, check that `SIF_PATH` in `Allrun.post-2` is an absolute and correct path to the `.sif` file.
