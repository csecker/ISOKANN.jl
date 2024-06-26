# ISOKANN

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://axsk.github.io/ISOKANN.jl/dev)

Implementation of the ISOKANN algorithm. For a reference see our paper https://doi.org/10.1063/5.0140764 .
Currently things are still fluctuating, so we have different implementations

- forced/isokann.jl - ISOKANN with adaptive sampling and optimal control for overdamped Langevin systems
- isomolly.jl - ISOKANN with adaptive sampling for Molly.jl systems (e.g. proteins)
- isosimple.jl - attempt at a cleaner version of isomolly.jl
- iso2.jl - ISOKANN 2 with multivariate memberships

After installing the package with `Pkg.add("https://github.com/axsk/ISOKANN.jl")` run a basic alanine dipeptide run with

```julia

using ISOKANN

iso = IsoRun()  # create the ISOKANN system/configuration
run!(iso)       # run it for iso.nd steps

plot_training(iso) # plot the training overview

# scatter plot of all initial points colored in  corresponding chi value
scatter_ramachandran(iso.data[1], iso.model)

# estimate the eigenvalue, i.e. the metastability
eigenvalue(iso.model, iso.data[1])

```


The big todos:
1. Merge optimal control into isomolly (requires a new Molly.jl sampler, almost done)
2. Use PCCA+ for higher dimensional chi functions (almost done)
3. Gather experience on larger molecules.
4. refactor

The most recent (but not actually recent) plot:
<img src="out/lastplot.png"/>
