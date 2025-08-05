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
        R568_2E7_svg = "results/escape_logos/R568_2E7_spike_DMS_line_logo_plot.svg",
    log:
        notebook = "results/logs/escape_logoplots_for_key_sites.txt",
    conda:
        os.path.join(config["pipeline_path"], "environment.yml"),
    notebook:
        "notebooks/escape_logoplots_for_key_sites.py.ipynb"


rule configure_dms_viz_R568_2E7:
    """Configure a JSON file for `dms-viz`."""
    input:
        phenotypes_csv="results/summaries/antibody_escape.csv",
        site_numbering_map=config["site_numbering_map"],
        nb="notebooks/configure_dms_viz_2E7.ipynb",
    output:
        dms_viz_json="results/dms-viz/dms-viz_R568_2E7.json",
        dms_viz_phenotypes="results/dms-viz/phenotypes_R568_2E7.csv",
        pdb_file="results/dms-viz/pdb_file_R568_2E7.pdb",
        nb="results/notebooks/configure_dms_viz_R568_2E7.ipynb",
    params:
        dms_viz_subdir=lambda _, output: os.path.dirname(output.dms_viz_json),
        pdb_id="8IOT",  # all-down XBB.1 spike structure
        chains="A,B,C",  # chains in the PDB to color
    log:
        "results/logs/configure_dms_viz_R568_2E7.txt",
    conda:
        "envs/dms-viz.yml"
    shell:
        """
        papermill {input.nb} {output.nb} \
            -p phenotypes_csv {input.phenotypes_csv} \
            -p site_numbering_map {input.site_numbering_map} \
            -p dms_viz_json {output.dms_viz_json} \
            -p dms_viz_phenotypes {output.dms_viz_phenotypes} \
            -p pdb_file {output.pdb_file} \
            -p dms_viz_subdir {params.dms_viz_subdir} \
            -p pdb_id {params.pdb_id} \
            -p chains {params.chains} \
            &> {log}
        """


# Files (Jupyter notebooks, HTML plots, or CSVs) that you want included in
# the HTML docs should be added to the nested dict `docs`:
docs["Additional files and plots"] = {
    "Reference to sequential site-numbering map": config["site_numbering_map"],
    "Structure data": {
        "JSON for dms-viz vizualization": rules.configure_dms_viz_R568_2E7.output.dms_viz_json,
            }
}


other_target_files.append([
    rules.escape_logos.output.R568_2E7_svg,
    rules.configure_dms_viz_R568_2E7.output.dms_viz_json,
     ] )
