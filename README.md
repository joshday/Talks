# Talks

This repo contains the content for every talk I've every given.

The content/slides could be anything from:

- Jupyter Notebooks
- Pluto Notebooks
- Apple Keynote Slides

## Opening Pluto Notebooks

`.jl` Files that start with something like:

```
### A Pluto.jl notebook ###
# v0.19.27
```

are [Pluto Notebooks](https://plutojl.org).  Pluto is a reactive programming environment that is specific to Julia and they don't display well in GitHub.

To open a Pluto notebook, you need:

1. Julia installed <https://julialang.org/downloads/>
2. Pluto installed.  Within the Julia REPL, run:
```julia
using Pkg
Pkg.add("Pluto")
```

Then to open the notebook, run:

```julia
using Pluto
Pluto.run()
```

This launches the Pluto home page in your web browser.  Use the "Open a Notebook" box to open the notebook file.
