### A Pluto.jl notebook ###
# v0.12.16

using Markdown
using InteractiveUtils

# ╔═╡ ca066b9e-3a9e-11eb-3621-856d2ec04c54
begin
	using Pkg
	Pkg.activate(".")
	Pkg.add(["CSV", "DataFrames", "Plots", "PlotlyBase", "PlutoUI", "HTTP", 
			 "SingularSpectrumAnalysis", "OnlineStats", "Parsers"]) 
	
	using Dates
	
	using CSV, DataFrames, Plots, PlutoUI, HTTP, 
		SingularSpectrumAnalysis, OnlineStats, FileTrees, 
		OrderedCollections, Parsers
	
	plotly()
	
	md"# (Setup Cell)"
end

# ╔═╡ df36a95c-3a9e-11eb-281d-a31ab51c5477
path = "/Users/joshday/datasets/nyc_yellow_taxi_2018"

# ╔═╡ da26b0ce-3a9e-11eb-3286-73f6403ef99c
tree = FileTree(path)

# ╔═╡ 23a8641a-3a9f-11eb-0f25-a9201afb2869
function f(file)
	@info file
	o = GroupBy(Date, CountMap(Int))
	itr = (Date(r.tpep_pickup_datetime[1:10]) => Parsers.parse(Int, r.passenger_count) for r in CSV.Rows(FileTrees.path(file), reusebuffer=true))
	fit!(o, itr)
end

# ╔═╡ e933545c-3a9e-11eb-0a4b-67d2daa6195d
res = reducevalues(merge, FileTrees.load(f, tree))

# ╔═╡ 576e45fc-3aa0-11eb-081d-fd8ae0a53f08
begin
	dt = Date(2018, 1, 1)
	plot(value(res)[dt], title=dt)
end

# ╔═╡ Cell order:
# ╠═ca066b9e-3a9e-11eb-3621-856d2ec04c54
# ╠═df36a95c-3a9e-11eb-281d-a31ab51c5477
# ╠═da26b0ce-3a9e-11eb-3286-73f6403ef99c
# ╠═23a8641a-3a9f-11eb-0f25-a9201afb2869
# ╠═e933545c-3a9e-11eb-0a4b-67d2daa6195d
# ╠═576e45fc-3aa0-11eb-081d-fd8ae0a53f08
