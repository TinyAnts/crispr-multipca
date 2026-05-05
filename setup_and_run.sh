#!/bin/bash
# =============================================================================
# setup_and_run.sh
# CRISPR MultiPCA — full replication script
#
# Usage:
#   bash setup_and_run.sh
#
# What this script does:
#   1. Creates a Python virtual environment
#   2. Installs all required libraries at pinned versions
#   3. Runs the CV experiment notebook (~8 hours on a standard CPU)
#   4. Runs the figures notebook to generate all 11 paper figures
#   5. Prints where results and figures are saved
#
# Requirements:
#   - Python 3.12 must be available as python3.12
#   - The data file must be present at: data/induce_seq.xlsx
#   - Run from the repository root directory
# =============================================================================

set -e  # exit immediately on any error

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$REPO_ROOT/venv"
RESULTS_DIR="$REPO_ROOT/results/cv_results_v15"
NB_DIR="$REPO_ROOT/notebooks"

echo "============================================================"
echo " CRISPR MultiPCA — Replication Script"
echo " Repo root : $REPO_ROOT"
echo " Results   : $RESULTS_DIR"
echo "============================================================"
echo ""

# ── Step 1: Create virtual environment ───────────────────────────────────────
echo "[1/4] Creating virtual environment..."
if [ ! -d "$VENV_DIR" ]; then
    python3.12 -m venv "$VENV_DIR"
    echo "      Virtual environment created at $VENV_DIR"
else
    echo "      Virtual environment already exists, skipping."
fi

# ── Step 2: Install dependencies ─────────────────────────────────────────────
echo ""
echo "[2/4] Installing dependencies from requirements.txt..."
"$VENV_DIR/bin/pip" install --upgrade pip --quiet
"$VENV_DIR/bin/pip" install -r "$REPO_ROOT/requirements.txt" --quiet
echo "      All dependencies installed."

# ── Step 3: Run CV experiment notebook ───────────────────────────────────────
echo ""
echo "[3/4] Running CV experiment notebook..."
echo "      WARNING: This step takes approximately 8 hours on a standard CPU."
echo "      Kernel PCA is the bottleneck (~60s per fold)."
echo "      Results are saved incrementally — safe to resume if interrupted."
echo ""

mkdir -p "$RESULTS_DIR"

"$VENV_DIR/bin/jupyter" nbconvert \
    --to notebook \
    --execute \
    --inplace \
    --ExecutePreprocessor.timeout=36000 \
    --ExecutePreprocessor.kernel_name=python3 \
    "$NB_DIR/01_cv_experiment.ipynb"

echo "      CV experiment complete. Results saved to: $RESULTS_DIR"

# ── Step 4: Run figures notebook ─────────────────────────────────────────────
echo ""
echo "[4/4] Generating figures..."

"$VENV_DIR/bin/jupyter" nbconvert \
    --to notebook \
    --execute \
    --inplace \
    --ExecutePreprocessor.timeout=3600 \
    --ExecutePreprocessor.kernel_name=python3 \
    "$NB_DIR/02_figures.ipynb"

echo "      Figures generated."

# ── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo "============================================================"
echo " DONE — Results are in the following locations:"
echo ""
echo "  CV results (JSON per seed):  $RESULTS_DIR/"
echo "  Summary CSV:                 $RESULTS_DIR/summary_10seeds.csv"
echo "  All seed results:            $RESULTS_DIR/all_seed_results.csv"
echo "  Friedman ANOVA:              $RESULTS_DIR/friedman_results.csv"
echo "  Post-hoc Wilcoxon:           $RESULTS_DIR/posthoc_wilcoxon.csv"
echo "  Effect sizes:                $RESULTS_DIR/effect_sizes.csv"
echo ""
echo "  Executed CV notebook:        $NB_DIR/01_cv_experiment.ipynb"
echo "  Executed figures notebook:   $NB_DIR/02_figures.ipynb"
echo "============================================================"
