### A Pluto.jl notebook ###
# v0.16.0

using Markdown
using InteractiveUtils

# ╔═╡ 8300c19e-2b7b-11ec-2b23-152a3b2aa5ff
begin 
	using Pkg 
	Pkg.activate(joinpath(@__DIR__, "2021", "StreamingDataWebinar"))
	using OnlineStats, PlutoUI, Plots
	
	PlutoUI.TableOfContents()
end

# ╔═╡ 54995f8b-3e31-46b3-b170-751f8d02b008
md"""
# Big Data Viz

## `Partition`

- `Partition` is for univariate data.
- It works by calculating an `OnlineStat` over nearly equal-sized sections of data.
- Similar to the visualizations created by R's [`tabplot`](https://mran.microsoft.com/snapshot/2015-11-17/web/packages/tabplot/vignettes/tabplot-vignette.html) package.
"""

# ╔═╡ 998618c8-47a7-4332-a609-8f4c9d66a19d
let
	o = Partition(Series(Mean(), Extrema()), 10)
	
	data = []
	
	@gif for i in 1:200
		y = i + 5randn()
	    fit!(o, y)
		plot(o)
		
		push!(data, y)
		scatter!(data, lab="data", alpha=.5, color="black", ms=3, legend=:topleft)
	end
end

# ╔═╡ 665aa606-04cf-4acb-b8ab-bb79d9815251
md"""
## `IndexedPartition`

- `IndexedPartition` is for bivariate data.
- An OnlineStat is calculated over nearly equal-sized bins of a reference (index) variable.
- I do not know of a comparable feature anywhere else.
"""

# ╔═╡ bfd3639f-1cbf-4a7d-9bd7-7f2dbb7b268f
let
	o = IndexedPartition(Float64, Hist(-10:.5:10), 100)
	
	x = randn(10^6)
	y = x + randn(10^6)
	
	fit!(o, zip(x,y))
	
	plot(o)
end

# ╔═╡ Cell order:
# ╠═8300c19e-2b7b-11ec-2b23-152a3b2aa5ff
# ╟─54995f8b-3e31-46b3-b170-751f8d02b008
# ╠═998618c8-47a7-4332-a609-8f4c9d66a19d
# ╟─665aa606-04cf-4acb-b8ab-bb79d9815251
# ╠═bfd3639f-1cbf-4a7d-9bd7-7f2dbb7b268f
