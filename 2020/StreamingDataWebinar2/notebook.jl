### A Pluto.jl notebook ###
# v0.12.16

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 36c852e4-358e-11eb-3a1c-1db62c80fe75
begin
	using Pkg
	Pkg.activate(".")
	Pkg.add(["CSV", "DataFrames", "Plots", "PlotlyBase", "PlutoUI", "HTTP", 
			 "SingularSpectrumAnalysis", "OnlineStats"]) 
	
	using Dates
	
	using CSV, DataFrames, Plots, PlutoUI, HTTP, 
		SingularSpectrumAnalysis, OnlineStats, FileTrees, 
		OrderedCollections
	
	plotly()
	
	md"# (Setup Cell)"
end

# ╔═╡ 7553cffa-3af4-11eb-2b57-09e6d539e0ad
using Serialization

# ╔═╡ 30378dfe-358f-11eb-2cee-93f28d27eedd
md"""
# OnlineStats and Big Data Viz

- Plot **infinitely-sized** datasets with `Partition` and `IndexedPartition`
"""

# ╔═╡ e2417a48-3aa6-11eb-0452-87acd4668298
md"""
#### `Partition` is for *univariate* data

- Fixed number of *bins*.
- When a bin "fills up", merge the oldest adjacent bins.
"""

# ╔═╡ 083ed30c-358f-11eb-1e00-d39b69dc24e3
let
	o = Partition(Series(Mean(), Extrema()), 20)
	
	y = randn()
	data = []
	
	@gif for _ in 1:1000
	    fit!(o, y += randn())
		plot(o)
		
		push!(data, y)
		scatter!(data, lab="data", alpha=.5, color="black", ms=2)
	end every 5
end

# ╔═╡ f0683062-3aa6-11eb-0ef5-ffee88344942
md"""
#### `IndexedPartition` is for *bivariate* data

- When you run out of bins, merge the closest bins (with respect to the `Index` variable)
"""

# ╔═╡ 9e929eba-358f-11eb-37e6-e5a11fc625bb
let
	o = IndexedPartition(Float64, KHist(20), 50)
	
	for _ in 1:10^8
	    fit!(o,  (randn(), randn()))
	end
	
	plot(o, title="IndexedPartition")
end

# ╔═╡ 1d417f1a-3590-11eb-30bd-ef67ed278086
md"""
# Kaggle's Huge Stock Market Dataset

- Source: [https://www.kaggle.com/borismarjanovic/price-volume-data-for-all-us-stocks-etfs](https://www.kaggle.com/borismarjanovic/price-volume-data-for-all-us-stocks-etfs)
- OHLC data for each stock/ETF (each is a separate CSV) traded in the US
- 7195 individual files!
- Over 700MB
"""

# ╔═╡ 728ecfd0-3591-11eb-188c-5314bb7193ab
begin
	stocks_path = "/Users/joshday/datasets/price-volume-data-for-all-us-stocks-etfs/Stocks/"
	files = readdir(stocks_path)
	CSV.File(joinpath(stocks_path, files[1]))
end

# ╔═╡ c1e7f72a-3977-11eb-141c-5fedf9f28052
files

# ╔═╡ a8ef967e-3977-11eb-2f3c-4ba98f27f17d
md"### Here's what the data looks like ($(files[1])):"

# ╔═╡ 33726db0-3592-11eb-283b-cf3b743f73e3
md"""
### Statistics/Plots Directly from CSV

- Via `CSV.File`
"""

# ╔═╡ 441696aa-3592-11eb-2893-4fdbdff898bb
function plot_high_low(stock; kw...)
    o = IndexedPartition(Date, Extrema(), 300)
	
	file = CSV.File(joinpath(stocks_path, "$stock.us.txt"))
	
	itr = ((row.Date => row.Low, row.Date => row.High) for row in file)
	
    fit!(o, itr)

    plot(o; xlab="Date", title=uppercase(stock) * " (nobs = $(nobs(o)))", 
		legend=false, kw...)
end

# ╔═╡ 57511ee4-3a82-11eb-0f9a-5fd6b724561f
stocklist = ["aapl", "msft", "ibm", "googl", "nflx"]

# ╔═╡ eb8e576e-3976-11eb-03c5-574581ced7be
@bind stock Select(stocklist)

# ╔═╡ 4c300f88-3592-11eb-2b8e-bbebc752fbda
plot_high_low(stock)

# ╔═╡ 27143716-3979-11eb-2956-43713e95577e
md"""
### But `CSV.File` loads the entire CSV!

- Even though we are using **OnlineStats**, the whole file is loaded into memory at once.

#### `CSV.Rows`

- Lazily read row-by-row from a CSV
- Minimal memory footprint
- At the cost of *no type inference* (everything is treated as a `String`)
"""

# ╔═╡ 6c55e810-3979-11eb-1554-8bbe852ad78c
function plot_high_low2(stock; kw...)
    o = IndexedPartition(Date, Extrema(), 500)
    for row in CSV.Rows("$stocks_path/$stock.us.txt", reusebuffer=true)
        dt = Date(row.Date, "yyyy-mm-dd")
        low = parse(Float64, row.Low)
        hi = parse(Float64, row.High)
        fit!(o, (dt => low, dt => hi))
    end
    t = uppercase(stock) * " (nobs = $(nobs(o)))"
    plot(o; xlab="Date", title=t, legend=false, kw...)
end

# ╔═╡ bda7bbbc-3979-11eb-0a3d-c3fc4ba6d270
plot_high_low2("aapl")

# ╔═╡ 144e1cda-3985-11eb-0b9d-79a647523103
md"""
# Analyzing Multiple Files at Once

- Working with only one CSV at a time is a big limitation.
- **FileTrees.jl**
  - Works even with files in nested directories.
  - Can be lazy/perform work in parallel.
"""

# ╔═╡ 469a12be-3985-11eb-0fc7-2337aaef745d
tree = FileTree(stocks_path);

# ╔═╡ 6102d522-3a2d-11eb-3c9e-0d0b061d8e65
md"""
### Let's start with a subset

- Multiple ways to match sub-trees
"""

# ╔═╡ 822af7b6-3a2d-11eb-1ed3-a357ea50d5a4
# glob
tree[glob"aap*"]

# ╔═╡ 5db8d474-39a2-11eb-1c53-05a793a936d9
# regular expression
subtree = tree[r"aapl|msft|nflx|ibm[^a-z]"]

# ╔═╡ 06b29ca8-3a2b-11eb-3ddb-9dabd6594c99
md"""
### It's easy to be lazy
"""

# ╔═╡ 4e589a08-3a2b-11eb-0721-6f5526d4282b
md"Be lazy? $(@bind be_lazy CheckBox())"

# ╔═╡ 4899b368-3a2b-11eb-2e62-c5be96bf0929
subtree_dfs = FileTrees.load(subtree, lazy=be_lazy) do file
	temp = DataFrame(CSV.File(joinpath(stocks_path, name(file))))
	temp[:, :file] .= name(file)
	temp
end

# ╔═╡ 5eda8bf6-3a2c-11eb-308d-eb3a38930db3
subtree_map = mapvalues(df -> maximum(df.High), subtree_dfs)

# ╔═╡ a260a500-3a2b-11eb-173f-554da8f3bd2c
subtree_map_exec = exec(subtree_map)

# ╔═╡ 0ab5c8be-3a2d-11eb-120e-ed3aef6c1979
get(subtree_map_exec["aapl.us.txt"])

# ╔═╡ 2c4b4c96-3a29-11eb-19d7-0332011a2da0
md"## Question: What is the Average Range for Every Stock?"

# ╔═╡ 634556c2-3a2b-11eb-1980-f7e4db31528b
# Load every file as a DataFrame
stock_dfs = FileTrees.load(tree) do file
	temp = DataFrame(CSV.File(FileTrees.path(file)))
	temp[:, :file] .= name(file)
	temp
end;

# ╔═╡ c747e93e-39a2-11eb-0764-6522bc968a71
# Join into one big DataFrame
all_stocks = reducevalues((a,b) -> vcat(a, b, cols=:union), stock_dfs)

# ╔═╡ e383913e-3a29-11eb-2484-1919b0dbfddd
# Group by the file name
all_stocks_gb = groupby(all_stocks, :file);

# ╔═╡ 4d95c308-3a2a-11eb-2e9e-05d438530ed4
# Calculate the mean range for each group
all_stocks_range = OrderedDict(
	k.file => mean(abs, v.High - v.Low) for (k, v) in pairs(all_stocks_gb)
)

# ╔═╡ 2bba5d76-3a31-11eb-3df7-37b087059c31
all_stocks_range["aapl.us.txt"]

# ╔═╡ e420f5f0-3a29-11eb-28af-21d717047c79
md"### The Lazy Version"

# ╔═╡ 8469f194-3a32-11eb-1120-218d9e2057f2
stock_dfs_lazy = FileTrees.load(tree, lazy=true) do file
	temp = CSV.File(joinpath(stocks_path, file.name))
	isempty(temp) ? 
		OrderedDict() :
		OrderedDict(file.name => mean(abs, temp.High - temp.Low))
end;

# ╔═╡ df4b995a-3a32-11eb-1d66-4fefdb9f2739
stocks_lazy_reduce = reducevalues(merge, stock_dfs_lazy)

# ╔═╡ 20219fc0-3a46-11eb-33f1-2760576843a8
stocks_lazy_reduce_exec = exec(stocks_lazy_reduce)

# ╔═╡ 87a6e100-3a82-11eb-3d85-27086ef0a726
Plots.bar(stocklist, [stocks_lazy_reduce_exec["$s.us.txt"] for s in stocklist])

# ╔═╡ 68037d4a-39b5-11eb-12b9-65e332b59594
md"""
# TrueFX API
- Foreign exchange market data
- Infinitely-sized data
"""

# ╔═╡ 6dcec3c4-39b5-11eb-201c-5d691c2d6a56
function get_truefx_data(q = "")
    endpoint = "https://webrates.truefx.com/rates/connect.html?f=csv&$q"
    hdr = [:pair, :utc, :big_bid_figure, :bid_points, :offer_bid_figure,
           :offer_points, :high, :low, :open]
    r = HTTP.get(endpoint)
    CSV.read(r.body, DataFrame; header=hdr, footerskip=1)
end

# ╔═╡ 805d8b7a-3af4-11eb-3b3a-3f28813f0859
begin
	touch("mystat")
	open("mystat", "w") do io 
		serialize(io, GroupBy(String, ExpandingHist(30)))
	end
end

# ╔═╡ c9d816fa-39b5-11eb-0ad4-cb6042cf58ef
@bind clock Clock()

# ╔═╡ 415cdfdc-39b6-11eb-200d-297230d10be7
let
	clock
	stat = deserialize("mystat")
	df = get_truefx_data()
	fit!(stat, zip(df.pair, df.bid_points))
	open("mystat", "w") do io 
		serialize(io, stat)
	end
	plot(
		plot(value(stat)["EUR/USD"], title="EUR/USD", lab=""), 
		plot(value(stat)["USD/JPY"], title="USD/JPY", lab=""), 
		plot(value(stat)["EUR/JPY"], title="EUR/JPY", lab=""), 
		layout=(3,1), link=:all,
	)
end

# ╔═╡ d2f45930-39b5-11eb-301c-ff71139584ae


# ╔═╡ 5b0677ee-3a5c-11eb-3a9c-45d40c2c1bca
md"""
# NYC Yellow Taxi Data (2018)

- Source: [https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page](https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page)
- Data on every single yellow taxi trip in 2018!
"""

# ╔═╡ 90231b30-3a5c-11eb-30ff-9909e7f5249f
taxipath = "/Users/joshday/datasets/nyc_yellow_taxi_2018"

# ╔═╡ 3f344196-3a5e-11eb-0531-7d5f0f3a79de
readdir(taxipath)

# ╔═╡ 99e1b424-3a5c-11eb-2bb8-2356da480530
sum(filesize("$taxipath/$file") for file in readdir(taxipath)) / 1024^3

# ╔═╡ 31d31f1a-3a5e-11eb-3dad-bb1d321c1cc7
md"### What the data looks like:"

# ╔═╡ ea01aedc-3a5c-11eb-2927-dfd23c1d6015
CSV.File("$taxipath/yellow_tripdata_2018-01.csv")

# ╔═╡ 28081bf6-3af7-11eb-22d6-2b0b40d637bb
md"### Question: What is the distribution of passenger count by date?"

# ╔═╡ 9828d8f4-3978-11eb-10c3-9d083af1c117
md"# Notebook Utils"

# ╔═╡ 9bf2bffe-3978-11eb-03ac-4153c0111f1a
spacer() = HTML(
	"""
	<div style='height:500px; width:100%; background: #FBFBFB;'>
	"""
)

# ╔═╡ 2c70f7e0-3590-11eb-2051-63fe28f8c7bf
spacer()

# ╔═╡ 8181af84-3978-11eb-18f1-b918c37ac814
spacer()

# ╔═╡ 698c0222-3979-11eb-01bb-cf3da1dd820d
spacer()

# ╔═╡ b60eac10-3985-11eb-1539-9fd75563a882
spacer()

# ╔═╡ 6eeae5a8-39b5-11eb-3688-fb83f9dc1cbe
spacer()

# ╔═╡ 5bb6894a-3a5c-11eb-3147-757fe7d6295c
spacer()

# ╔═╡ Cell order:
# ╟─36c852e4-358e-11eb-3a1c-1db62c80fe75
# ╟─30378dfe-358f-11eb-2cee-93f28d27eedd
# ╟─e2417a48-3aa6-11eb-0452-87acd4668298
# ╠═083ed30c-358f-11eb-1e00-d39b69dc24e3
# ╟─f0683062-3aa6-11eb-0ef5-ffee88344942
# ╠═9e929eba-358f-11eb-37e6-e5a11fc625bb
# ╟─2c70f7e0-3590-11eb-2051-63fe28f8c7bf
# ╟─1d417f1a-3590-11eb-30bd-ef67ed278086
# ╟─c1e7f72a-3977-11eb-141c-5fedf9f28052
# ╟─a8ef967e-3977-11eb-2f3c-4ba98f27f17d
# ╟─728ecfd0-3591-11eb-188c-5314bb7193ab
# ╟─33726db0-3592-11eb-283b-cf3b743f73e3
# ╟─441696aa-3592-11eb-2893-4fdbdff898bb
# ╟─57511ee4-3a82-11eb-0f9a-5fd6b724561f
# ╟─eb8e576e-3976-11eb-03c5-574581ced7be
# ╟─4c300f88-3592-11eb-2b8e-bbebc752fbda
# ╟─8181af84-3978-11eb-18f1-b918c37ac814
# ╟─27143716-3979-11eb-2956-43713e95577e
# ╟─6c55e810-3979-11eb-1554-8bbe852ad78c
# ╟─bda7bbbc-3979-11eb-0a3d-c3fc4ba6d270
# ╟─698c0222-3979-11eb-01bb-cf3da1dd820d
# ╟─144e1cda-3985-11eb-0b9d-79a647523103
# ╠═469a12be-3985-11eb-0fc7-2337aaef745d
# ╟─6102d522-3a2d-11eb-3c9e-0d0b061d8e65
# ╠═822af7b6-3a2d-11eb-1ed3-a357ea50d5a4
# ╠═5db8d474-39a2-11eb-1c53-05a793a936d9
# ╟─06b29ca8-3a2b-11eb-3ddb-9dabd6594c99
# ╟─4e589a08-3a2b-11eb-0721-6f5526d4282b
# ╠═4899b368-3a2b-11eb-2e62-c5be96bf0929
# ╠═5eda8bf6-3a2c-11eb-308d-eb3a38930db3
# ╠═a260a500-3a2b-11eb-173f-554da8f3bd2c
# ╠═0ab5c8be-3a2d-11eb-120e-ed3aef6c1979
# ╟─2c4b4c96-3a29-11eb-19d7-0332011a2da0
# ╠═634556c2-3a2b-11eb-1980-f7e4db31528b
# ╠═c747e93e-39a2-11eb-0764-6522bc968a71
# ╠═e383913e-3a29-11eb-2484-1919b0dbfddd
# ╠═4d95c308-3a2a-11eb-2e9e-05d438530ed4
# ╠═2bba5d76-3a31-11eb-3df7-37b087059c31
# ╟─e420f5f0-3a29-11eb-28af-21d717047c79
# ╠═8469f194-3a32-11eb-1120-218d9e2057f2
# ╠═df4b995a-3a32-11eb-1d66-4fefdb9f2739
# ╠═20219fc0-3a46-11eb-33f1-2760576843a8
# ╠═87a6e100-3a82-11eb-3d85-27086ef0a726
# ╟─b60eac10-3985-11eb-1539-9fd75563a882
# ╟─68037d4a-39b5-11eb-12b9-65e332b59594
# ╠═6dcec3c4-39b5-11eb-201c-5d691c2d6a56
# ╠═7553cffa-3af4-11eb-2b57-09e6d539e0ad
# ╠═805d8b7a-3af4-11eb-3b3a-3f28813f0859
# ╟─c9d816fa-39b5-11eb-0ad4-cb6042cf58ef
# ╠═415cdfdc-39b6-11eb-200d-297230d10be7
# ╟─d2f45930-39b5-11eb-301c-ff71139584ae
# ╟─6eeae5a8-39b5-11eb-3688-fb83f9dc1cbe
# ╟─5b0677ee-3a5c-11eb-3a9c-45d40c2c1bca
# ╟─90231b30-3a5c-11eb-30ff-9909e7f5249f
# ╟─3f344196-3a5e-11eb-0531-7d5f0f3a79de
# ╟─99e1b424-3a5c-11eb-2bb8-2356da480530
# ╟─31d31f1a-3a5e-11eb-3dad-bb1d321c1cc7
# ╠═ea01aedc-3a5c-11eb-2927-dfd23c1d6015
# ╟─28081bf6-3af7-11eb-22d6-2b0b40d637bb
# ╟─5bb6894a-3a5c-11eb-3147-757fe7d6295c
# ╟─9828d8f4-3978-11eb-10c3-9d083af1c117
# ╟─9bf2bffe-3978-11eb-03ac-4153c0111f1a
