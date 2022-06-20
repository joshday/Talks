### A Pluto.jl notebook ###
# v0.19.8

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 8cb0914e-ecc1-11ec-309e-7b022f95e17f
begin 
	using Pkg
	Pkg.activate(@__DIR__)

	using PlutoUI
	using Plots

	PlutoUI.TableOfContents()
end

# ╔═╡ ca63f9c5-b5e3-4872-8858-92028be00eb4
md"""
# What is Pluto.jl?

- Pluto is a *reactive* notebook environment that is based on standard Julia (.jl) files.
- Changes to a variable will propogate through the entire notebook.
"""

# ╔═╡ 31a24d1f-f05c-4dea-b06a-a22010c8b704
n = 10  # Change this value

# ╔═╡ 9649a4f9-c8bd-4103-b75c-372d076cb6d1
scatter(randn(n))

# ╔═╡ 03a31c4a-9230-45da-95ae-1b201b3bddfc
md"""
## Key Differences from Jupyter Notebooks

#### 1. Pluto is specific to Julia

You cannot change the kernel to R/Python/etc.  You can, however, use Rcall.jl or PyCall.jl to call R & Python from Julia.

#### 2. The order of cells does not matter 

Pluto automatically determines the order in which cells should be run.  This allows you to put key findings of a long analysis at the top of the notebook.

- Due to this, there are some things you are not allowed to do, such as define a variable twice in two different cells.

#### 3. Output displays *above* the cell

Focus is on what the code generates, not the code itself.
"""

# ╔═╡ 0f2f4a72-a345-471f-814a-bfe4743e15f8
md"""
# Interactivity

- Beyond changing code, you can *bind* variables to UI elements.
"""

# ╔═╡ 8fd58053-792e-43f7-b033-afbf0f1144db
@bind text TextField(default="Hello")

# ╔═╡ 48ef4554-8773-40ec-9eb6-bdae2542f6d3
"The text entered above is: $text"

# ╔═╡ 23e0090d-cf72-42bf-8a8e-338679165c30
md"""
# Display

- The `TextField` above is really just an [html <input> tag](https://www.w3schools.com/tags/tag_input.asp) under the hood.


"""

# ╔═╡ Cell order:
# ╟─8cb0914e-ecc1-11ec-309e-7b022f95e17f
# ╟─ca63f9c5-b5e3-4872-8858-92028be00eb4
# ╠═31a24d1f-f05c-4dea-b06a-a22010c8b704
# ╠═9649a4f9-c8bd-4103-b75c-372d076cb6d1
# ╟─03a31c4a-9230-45da-95ae-1b201b3bddfc
# ╟─0f2f4a72-a345-471f-814a-bfe4743e15f8
# ╠═8fd58053-792e-43f7-b033-afbf0f1144db
# ╠═48ef4554-8773-40ec-9eb6-bdae2542f6d3
# ╠═23e0090d-cf72-42bf-8a8e-338679165c30
