### A Pluto.jl notebook ###
# v0.12.16

using Markdown
using InteractiveUtils

# ╔═╡ 7fbe3792-3a8a-11eb-22bb-ede9bb11122d
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

# ╔═╡ d12b642e-3a8a-11eb-3905-1dfa451c5abd
taxipath = "/Users/joshday/datasets/nyc_yellow_taxi_2018"

# ╔═╡ 146e1176-3a8d-11eb-1a4d-ddc32fccf5bb
function passenger_count_by_date(path)
	o = GroupBy(Date, CountMap(Int))
	
	for file in filter(endswith(".csv"), readdir(path))
		@info file
		for row in CSV.Rows(joinpath(path, file), reusebuffer=true)
			dt = Date(row.tpep_pickup_datetime[1:10])
			val = Parsers.parse(Int, row.passenger_count)
			fit!(o, dt => val)
		end
	end
	
	o
end

# ╔═╡ 3cbabcba-3a8d-11eb-2678-3bd14aa71388
res = passenger_count_by_date(taxipath)

# ╔═╡ fe8d3786-3a9d-11eb-36ae-7302e3acd409
begin
	dt = Date(2018, 1, 1)
	plot(value(res)[dt], title=dt)
end

# ╔═╡ 4ade6556-3a9e-11eb-1843-9185dccfff43
html"<div style='height:400px'>"

# ╔═╡ Cell order:
# ╠═7fbe3792-3a8a-11eb-22bb-ede9bb11122d
# ╟─d12b642e-3a8a-11eb-3905-1dfa451c5abd
# ╠═146e1176-3a8d-11eb-1a4d-ddc32fccf5bb
# ╠═3cbabcba-3a8d-11eb-2678-3bd14aa71388
# ╠═fe8d3786-3a9d-11eb-36ae-7302e3acd409
# ╟─4ade6556-3a9e-11eb-1843-9185dccfff43
