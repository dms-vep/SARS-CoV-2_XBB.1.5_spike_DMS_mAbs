"""Custom rules used in the ``snakemake`` pipeline.

This file is included by the pipeline ``Snakefile``.

"""


rule spatial_distances:
    """Get spatial distances from PDB."""
    input: 
        pdb="data/PDBs/aligned_spike_TM.pdb",
    output:
        csv="results/spatial_distances/spatial_distances.csv",
    params:
        target_chains=["A", "B", "C"],
    log:
        log="results/logs/spatial_distances.txt",
    conda:
        os.path.join(config["pipeline_path"], "environment.yml")
    script:
        "scripts/spatial_distances.py"


rule escape_logos:
    """Make logo plots for each antibody"""
    input:
        per_antibody_escape = "results/summaries/antibody_escape.csv",
    output:
        mAb_2E7_svg = "results/escape_logos/mAb_2E7_spike_DMS_line_logo_plot.svg",
    log:
        notebook = "results/logs/escape_logoplots_for_key_sites.txt",
    conda:
        os.path.join(config["pipeline_path"], "environment.yml"),
    notebook:
        "notebooks/escape_logoplots_for_key_sites.py.ipynb"


# Files (Jupyter notebooks, HTML plots, or CSVs) that you want included in
# the HTML docs should be added to the nested dict `docs`:
docs["Site numbering"] = {
    "Reference to sequential site-numbering map": config["site_numbering_map"],
}

other_target_files.append([
    rules.escape_logos.output.mAb_2E7_svg,
     ] )
