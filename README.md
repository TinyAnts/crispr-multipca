# CRISPR MultiPCA — Replication Repository

**Paper:** *Comparative Dimensionality Reduction and Tree-Based Classification of CRISPR-Cas9 INDUCE-seq Off-Target Sites: A Multi-Method Study with Evaluation Metrics*

**Authors:** Nagarajan Shunmugam, Maciej Powierża, Maciej Huk

---

## Repository Contents

```
crispr-multipca/
├── README.md                     This file
├── requirements.txt              Pinned library versions
├── setup_and_run.sh              Power script — full replication from scratch
├── data/
│   └── induce_seq.xlsx           INDUCE-seq dataset (Dobbs et al. 2022)
├── notebooks/
│   ├── 01_cv_experiment.ipynb    10×10-fold CV experiment (generates all CSVs)
│   └── 02_figures.ipynb          Paper figures (reads CSVs, generates all 11 figures)
└── results/
    └── cv_results_v15/           Created automatically — populated by 01_cv_experiment.ipynb
```

---

## Requirements

- **Python 3.12**
- **Linux or macOS** (the power script is a bash script)
- ~8 hours of CPU time for the full CV experiment (Kernel PCA is the bottleneck)
- At least 8 GB RAM recommended

All Python dependencies are pinned in `requirements.txt`:

| Package | Version |
|---|---|
| numpy | 2.0.2 |
| pandas | 2.2.2 |
| scikit-learn | 1.6.1 |
| scipy | 1.16.3 |
| matplotlib | 3.10.0 |
| seaborn | 0.13.2 |
| pycm | 4.6 |
| openpyxl | 3.1.5 |
| jupyter | 1.1.1 |
| nbconvert | 7.16.6 |

---

## Quickstart — Full Replication

Clone the repository and run the power script from the repo root:

```bash
git clone https://github.com/tinyants/crispr-multipca
cd crispr-multipca
bash setup_and_run.sh
```

The script will:
1. Create a Python 3.12 virtual environment at `venv/`
2. Install all dependencies at pinned versions
3. Execute `01_cv_experiment.ipynb` — runs 10×10-fold CV across all 15 method combinations (~8 hours)
4. Execute `02_figures.ipynb` — generates all 11 paper figures (~10 minutes)
5. Print the location of all output files

Results are saved **incrementally** (one JSON file per seed). If the run is interrupted, re-running the script will skip completed seeds and resume from where it left off.

---

## Manual Step-by-Step (without the power script)

```bash
# 1. Create and activate virtual environment
python3.12 -m venv venv
source venv/bin/activate

# 2. Install dependencies
pip install -r requirements.txt

# 3. Launch Jupyter and run notebooks in order
jupyter notebook
# Open notebooks/01_cv_experiment.ipynb → Run All (takes ~8 hours)
# Open notebooks/02_figures.ipynb → Run All (takes ~10 minutes)
```

---

## Output Files

After running `01_cv_experiment.ipynb`, the following files are created in `results/cv_results_v15/`:

| File | Contents |
|---|---|
| `seed_0_XXXXXXXX.json` ... `seed_9_XXXXXXXX.json` | Per-seed results for all 15 combinations |
| `summary_10seeds.csv` | Mean ± std across 10 seeds for each combination |
| `all_seed_results.csv` | Full results table (150 rows: 10 seeds × 15 combinations) |
| `friedman_results.csv` | Friedman ANOVA results per metric and classifier |
| `posthoc_wilcoxon.csv` | Post-hoc pairwise Wilcoxon results (Holm-corrected) |
| `effect_sizes.csv` | Kendall's W, Wilcoxon r, and Shapiro-Wilk results |

---

## Experiment Design

- **Dataset:** INDUCE-seq (Dobbs et al. 2022) — 9,877 DSB sites filtered to top 15 contigs → 7,863 observations, 34 features, 15 classes
- **Decomposition methods:** Standard PCA, Kernel PCA (RBF), Sparse PCA, Truncated SVD, Factor Analysis — all reducing to 16 components
- **Classifiers:** Decision Tree, Random Forest, Extra Trees
- **Evaluation:** 10×10-fold stratified cross-validation (10 independent seeds via MD5 hashing)
- **Seed management:** Option B — global block-repeated Mersenne Twister (MT19937), no fixed `random_state` on any model constructor
- **Statistical tests:** Friedman ANOVA + post-hoc Wilcoxon (Holm–Bonferroni correction), Kendall's W effect sizes

---

## MCEN Implementation

The corrected Overall MCEN metric (Delgado & Núñez-González, 2019) is implemented directly inside both notebooks. It fixes two bugs present in PyCM's implementation:
1. `Mj` denominator — diagonal subtracted once (TP+FP+FN), not twice (FP+FN only)
2. Weight denominator — Delgado alpha=0.5, not PyCM's alpha=0 (binary) or alpha=1 (multiclass)

---

## Citation

If you use this code or data, please cite:

> Shunmugam, N., Powierża, M., Huk, M. Comparative Dimensionality Reduction and Tree-Based Classification of CRISPR-Cas9 INDUCE-seq Off-Target Sites: A Multi-Method Study with Evaluation Metrics. [Journal] (2025).

---

## Data Availability

The original INDUCE-seq dataset is publicly available as part of Dobbs et al. (2022), *Nature Communications* 13, 3989. The version used in this study (`induce_seq.xlsx`) is included in the `data/` directory of this repository.
