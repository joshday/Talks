### A Pluto.jl notebook ###
# v0.19.45

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

# ╔═╡ 829bd170-07d7-11ef-2c11-494482da4d69
begin
	using Cobweb: Cobweb, h
	using PlotlyLight
	using PlutoUI
	md"""
	(notebook setup)
	$(PlutoUI.TableOfContents())
	$(HTML("<style>h1 { padding-top: 200px; }</style>"))
	$(HTML("<style>h2 { padding-top: 100px; }</style>"))
	$(HTML("<style>h3 { padding-top: 50px; }</style>"))
	$(HTML("<style>h4 { padding-top: 25px; }</style>"))
	"""
end

# ╔═╡ bdb6766f-c39f-4978-b866-9a303394d8a3
using CSV, DataFrames

# ╔═╡ 15aecd6a-c8d4-4510-bc15-01dc60336da0
using JSON3, HTTP

# ╔═╡ 876e4065-3741-4144-b35b-871a1554ada1
using SQLite, DBInterface

# ╔═╡ 2d9c9bf3-b62e-4f08-8d25-43847037a6b9
# Necessary for using `mean`, `std`, etc.
using Statistics

# ╔═╡ 760218bd-b5ae-4b95-8f53-430d484d1d29
using Serialization

# ╔═╡ fa5320e4-d694-47ff-951a-29a1f5be2256
md"""
# Working With Data

!!! note "Types of Data"
	Data comes in infinitely many forms.  In this notebook, we'll cover:
	1. Getting data into Julia from a variety of formats (CSV, JSON, Databases, etc.).
	2. Manipulating data in Julia.
"""

# ╔═╡ 8e05339e-938f-42ed-9028-8d68f6f85107
md"""
# Getting Data into Julia

!!! note "No Built-In DataFrame"
	- Similar to Python, there is not built in data type for tabular data in Julia.  - However, "competing" implementations ([DataFrames](https://github.com/JuliaData/DataFrames.jl), [TypedTables](https://github.com/JuliaData/TypedTables.jl), etc.) follow a consistent interface ([Tables](https://github.com/JuliaData/Tables)).
	- DataFrames is the most popular package for tabular data.

!!! aside "Tables.jl"
	- The Tables interface provides a consistent way of *iterating* over tabular data (either by column or by row).  The interface even allows iterating over larger-than-memory datasets.  We'll see an example of how this is done later in the notebook.

	- Due to this interface (and Julia's composability), most data processing/modeling packages work with any Tables-compliant data structure.

	- For most users, this is probably just an implementation detail that won't affect you, but it's a really cool package/feature.
"""

# ╔═╡ 9ffdb7e7-7951-4ea1-a83b-47bc9609b947
md"""
## Delimited Files

- A delimited file is a text file that uses a specified character (most often comma or tab, referred to as CSV and TSV respectively) to separate data values.

### [CSV.jl](https://github.com/JuliaData/CSV.jl)

!!! note "CSV.read"
	The core function is `CSV.read(file, sink)`.  The `sink` argument is what datatype you want the read-in data to be, e.g. a `DataFrame`.

	---

	There is also a `CSV.write` function.  This is more straightforward than reading from the infinitely many variations of CSV files, so we won't cover it in this course.  The documentation for writing is available [here](https://csv.juliadata.org/stable/writing.html#CSV.write).
"""

# ╔═╡ c11d767f-b595-4f0d-8b82-a839c3695360
md"""
### Example 1: Palmer Penguins

Here we'll download the popular "Palmer Penguins" dataset and read the CSV as a DataFrame.
"""

# ╔═╡ 8bcddeeb-a6f2-4546-b56e-3056f2edc91e
begin
	penguins_url = "https://raw.githubusercontent.com/mwaskom/seaborn-data/master/penguins.csv"
	
	penguins_file = download(penguins_url)
	
	df = CSV.read(penguins_file, DataFrame)
end

# ╔═╡ 65935cfe-61ac-4cf5-a2a8-dd33a40565ab
md"""
#### What if the CSV is Messy?
"""

# ╔═╡ d21d3e07-2cd9-4be9-b331-bffca112bc79
md"""
!!! note "Poorly Formatted CSVs"
	Note that this worked without providing any information about what the CSV looks like.  CSV has sensible defaults that will work out-of-the-box with a "well-formatted" CSV file.

	---
	
	CSV.jl offers many options for parsing the file.  See [https://csv.juliadata.org/stable/reading.html](https://csv.juliadata.org/stable/reading.html) for a detailed list of keyword arguments that can be passed to `CSV.read`.  Common options I use are:


	- `normalizenames = true`: This will change the names in the header (first line of file) to play nicer with Julia.  E.g. `field one --> :field_one`, `1 -> :_1`. 
	- `skipto = n`: Skip to row `n` to start reading data.
	- `dateformat = "yyyy/mm/dd"`: Change the format of `Date`s/`DateTime`s.  Otherwise they will be read into Julia as a `String`.
	- `types`: Specify the column types.
"""

# ╔═╡ c0d90583-c612-4337-86cc-b59a8d92a7a8
md"""
!!! aside "Aside: Symbols"
	In Julia, a variable name is stored as a `Symbol`.  You can create `Symbol`s that are invalid identifiers, but they can be cumbersome to work with.  Hence, `normalizenames` above is a nice feature.
"""

# ╔═╡ 39841f5b-332e-4b42-ae13-b276a9c76de3
Symbol("hello")

# ╔═╡ 6769ecc2-923a-4364-af6d-0ed3a3d2db9e
Symbol("I am an invalid identifier")

# ╔═╡ 07aa119e-20c8-43f5-aec8-3f186397a654
begin
	# You can still use invalid names via the `var` string macro
	var"bad name" = 1
	
	var"bad name"
end

# ╔═╡ 46cd8c2d-4691-4d22-aa0f-f89497a30bee
md"""
### Example 2: Big CSVs

!!! note "Tables Iterator"
	Suppose you have a CSV that is larger than the RAM of your laptop?  How do you work with it?

	`CSV.Rows` is a data structure for lazily iterating over the rows of a CSV file.  The downside is that all the data will be an `AbstractString` unless you specify the `types`.

	---

	We'll use the penguins data to demonstrate `CSV.Rows` (even though it is much smaller than memory!).  I have successfully used this technique to analyze larger-than-RAM data.  It's just unfeasible to have all the attendees of a course download a 20Gb CSV.
"""

# ╔═╡ 3b1235b6-8bba-4c95-9c42-bbaf033871b2
penguins_rows = CSV.Rows(penguins_file)

# ╔═╡ c3f5bbc7-4dae-4408-a293-180ec22b978d
# A Tables.Row will act like a `NamedTuple`
@info first(penguins_rows)

# ╔═╡ c31adb44-ebc5-414f-83fa-70ab458193ac
# If we used `CSV.read` this would be an `Int`, not a `String`
first(penguins_rows).body_mass_g

# ╔═╡ a0b74bac-f53a-4cfe-9303-b6bd6d3e9bc6
# Example: Getting the sum of flipper_length_mm
let 
	result = 0
	# This only has one row in memory at a time!
	for x in penguins_rows 
		if !ismissing(x.flipper_length_mm)
			result += parse(Int, x.flipper_length_mm)
		end
	end
	result
end

# ╔═╡ d65f62ca-52cf-4bc1-bdb2-db45e2010360
md"""
!!! aside "Aside: Generators"
	We could also use a generator rather than a for loop!
"""

# ╔═╡ adf74af9-241e-4d1e-a0f2-8d889964a5a9
sum(
	parse(Int, x.flipper_length_mm) for x in penguins_rows if !ismissing(x.flipper_length_mm)
)

# ╔═╡ a2adff69-2e57-4601-b553-e0d2a1eeb1bc
md"""
## JSON (Javascript Object Notation)

- For better or worse, this is often the language used to pass data around the web.

### [JSON3.jl](https://github.com/quinnj/JSON3.jl)

!!! aside "Why are There Three of Them?" 
	JSON.jl and JSON2.jl also exist.  Why?

	These three packages have entirely different designs.  JSON2 is deprecated in favor of JSON3.  So really there are just two competing designs.  We are choosing to cover JSON3 since it in general has better performance as well as better support for (de)serializing Julia structs.

!!! note "Reading JSON"
	JSON3 lets you read JSON data from both `String`s and raw (`Vector{UInt8}`) data.  

	If you use e.g. [HTTP](https://github.com/JuliaWeb/HTTP.jl) to request data from an API, the response body will be a `Vector{UInt8}`.  There's no need to convert this to a `String` before reading it with JSON3.
"""

# ╔═╡ 56dc1e5b-6190-44d0-9dd5-c5b43eb048d8
md"""
### Example 1: HTTP + JSON3
Here we'll retrieve data from a web API and interpret the response with JSON3.

!!! aside "XKCD Webcomic"
	The XKCD webcomic is a popular webcomic (among nerds) that regularly covers topics like math, science, and programming.

	The author provides a JSON API to retrieve metadata about every comic he's written (this is what powers the [XKCD.jl](https://github.com/joshday/XKCD.jl) package).  In this example, we'll look at one of my favorite comics.
"""

# ╔═╡ 36fca49a-34ee-46e5-948f-c57bbb7b603c
# The HTTP.Response from retrieving JSON metadata about an XKCD comic
xkcd_res = HTTP.get("https://xkcd.com/552/info.0.json")

# ╔═╡ 7986066c-4bdd-459b-90b3-4b7a642e7888
# The response body is raw Vector{UInt8} data
xkcd_res.body

# ╔═╡ 90012400-b655-4b11-810c-13e880b1a0cc
# We can convert the raw data to a String like this
# JSON3 does not require this
# String(data::Vector{UInt8}) will empty the data vector, so we'll use a copy
String(copy(xkcd_res.body))

# ╔═╡ 76a9e7ba-a1a1-45f0-a95e-f7975b5095ab
# JSON3 can read from the raw data directly
xkcd_obj = JSON3.read(xkcd_res.body)

# ╔═╡ 930cf068-4b2b-4baf-b485-6ece1cc02364
HTML("<img src='$(xkcd_obj.img)'>")

# ╔═╡ af72a6a5-0bc6-4287-be83-86c546e3baf3
Markdown.parse("> $(xkcd_obj.alt)")

# ╔═╡ f9f40a9f-b77c-4278-804f-da1605d57ffa
md"""
### Example 2: Struct (De)serialization

!!! note "(De)serialization"
	Suppose you have a Julia `struct` and you want to be able to write (serialize) it to JSON and also read (deserialize) it back into Julia.

	---

	Note that for complicated types, you need to use the [StructTypes](https://github.com/JuliaData/StructTypes.jl) package to define the read/write interface.
"""

# ╔═╡ 63afafdb-4583-4558-9d0e-2c55b34c0122
struct Thing 
	x::Int 
	y::String 
end

# ╔═╡ f1d96853-4bf2-457a-ae4e-c01eacccfafb
thing = Thing(1, "two")

# ╔═╡ 7e3d8422-9e75-4bad-9787-0a97604294b2
# Serializing/writing works out of the box
thing_write = JSON3.write(thing)

# ╔═╡ 617d2deb-0d7d-43e5-b24a-f1e863db0826
# So does reading...but the `Thing` type didn't survive the round trip.
# This is read in as a `JSON3.Object`.
thing_read = JSON3.read(thing_write)

# ╔═╡ d2b47884-a0e2-4d63-bdae-e1c549dca8fe
# So instead we tell JSON3 what type we want to read in the data as
thing_read2 = JSON3.read(thing_write, Thing)

# ╔═╡ cc575e83-d226-4a0f-86f3-f2499b91e72c
# Many other "sinks" work out of the box as well
JSON3.read(thing_write, NamedTuple)

# ╔═╡ 5f2deb6f-9b5f-4ed4-b661-5e55f657a70b
md"""
## Databases

- [DBInterface.jl](https://github.com/JuliaDatabases/DBInterface.jl)
  - [SQLite.jl](https://github.com/JuliaDatabases/SQLite.jl)
  - [MySQL.jl](https://github.com/JuliaDatabases/MySQL.jl)
  - [LibPQ.jl](https://github.com/iamed2/LibPQ.jl) (Postgres)
  - and more

!!! aside "SQLite"
	In this notebook, we'll stick with SQLite since it's one of the simplest databases to work with.

	However, you can swap to a different database and the `DBInterface.execute` command will still work!
"""

# ╔═╡ bf06fd7f-1248-4897-82b5-a03af9582b90
md"""
### Example: [SQLite.jl](https://github.com/JuliaDatabases/SQLite.jl)
"""

# ╔═╡ 7be196e9-ec18-486f-a8fa-116ea451468b
begin
	db = SQLite.DB()  # An in-memory instance of a SQLite database

	# Load a Tables data source as a table in the DataBase
	SQLite.load!(df, db, "penguins")

	SQLite.tables(db)
end

# ╔═╡ aab3524d-eafb-4bad-aaca-0821f2d02476
md"""
!!! note "Queries"
	Queries (results of `DBInterface.execute`) are Tables.jl-compliant tables.  Thus they can be converted into whichever data type you wish.
"""

# ╔═╡ 3db58a19-b3e7-4b06-a091-caccb3733d42
let
	stmt = "SELECT * from penguins WHERE bill_length_mm > 50"
	
	q = DBInterface.execute(db, stmt) 
	
	DataFrame(q)
end

# ╔═╡ 530ec008-a40b-4b63-8d1d-5967866594d5
md"""
# DataFrames

- [DataFrames.jl Cheatsheet](https://ahsmart.com/assets/pages/data-wrangling-with-data-frames-jl-cheat-sheet/DataFramesCheatSheet_v1.x_rev1.pdf?ref=juliafordatascience.com)

!!! note "DataFrames Features"
	**DataFrames** is a performant, full-featured, [well-documented](https://dataframes.juliadata.org/stable/) tabular data library.

	You'll find many tutorials and books on how to use DataFrames, but the official docs are my go-to resource.

	---

	We'll continue to use the Palmer Penguins data as an example.
"""

# ╔═╡ 722456c8-b7c8-4500-9d7b-9b0ca019bc58
# Summary Statistics about Columns
describe(df)

# ╔═╡ 9b314950-e47d-4c16-9e52-0a02235b205b
md"""
## Selecting Data

!!! note "Selectors"
	- There are many ways to select a subset of columns.
	- `select(df, selector)`
	- `select` always returns a DataFrame with the same number of rows as the source.
	- A mutating version (`select!`) is also available.
	- `transform` (and `transform!`) acts the same as `select` but keeps all the original columns.
"""

# ╔═╡ d3032cf2-4870-4f0e-976e-78d33a375244
# Utility macro for displaying expression correctly in dropdown menu
macro selpair(ex)
	Base.remove_linenums!(ex)
	esc(:($ex => $(string(ex))))
end

# ╔═╡ d459bbba-f5f4-4616-b51c-312f235fd255
begin 
	selectors = [
		@selpair("species"), 
		@selpair(:island), 
		@selpair(3),
		@selpair(Not(:species)),
		@selpair(Between(1, :island)),
		@selpair(Not(Between(1, 3))),
		@selpair(All()),
		@selpair(Cols(1, Between(4, 5))),
		@selpair([1, 2, 4, 5]),
		@selpair(:bill_length_mm => x -> x .+ 100),
		@selpair(:bill_length_mm => (x -> x .+ 100) => :bill_length_mm_add100),
		@selpair(r"mm")
	]


	md"""
	Choose a selector: $(@bind sel Select(selectors))
	"""
end

# ╔═╡ 8ecc4873-b6af-4bfe-bb18-418ec9937381
# e.g. `select(df, :species)`
select(df, sel)

# ╔═╡ 045a19ee-6a22-4446-a378-2e8485293357
md"""
## Filtering Data

!!! note "Filtering"
	Select a subset of rows for which an input function returns `true`.
"""

# ╔═╡ 392de5f3-da48-4f75-9295-95feb90954ac
filter(df) do row 
	!ismissing(row.bill_length_mm) && row.bill_length_mm > 45
end

# ╔═╡ a4e12565-2736-4b67-ac74-9a3b25c4605b
# You can also pass a `selector => function` pair (same result as above)
filter(:bill_length_mm => x -> !ismissing(x) && x > 45, df);

# ╔═╡ e010ba8a-fd49-4621-a159-5cdef2a1e6c1
md"""
## Split-Apply-Combine

!!! note "A Common Workflow"

	Many data analysis tasks can be reduced to three steps:
	
	1. Split data into groups.
	2. Apply a function to each group.
	3. Combine the results.

	See Hadley Wickham's widely cited [paper](http://www.jstatsoft.org/v40/i01) on the subject.

	---

	In **DataFrames**, this is `gdf = groupby` -> `combine(gdf, apply)`
"""

# ╔═╡ bdc04231-69d9-4c23-9266-60996714c388
md"""
### Example 1: Population Sizes
"""

# ╔═╡ a97bf75f-7c3b-43ed-aee0-001eeb347668
let 
	df2 = select(dropmissing(df), Not(:sex))
	
	g = groupby(df2, [:species, :island])

	c = combine(g, nrow, proprow)
end

# ╔═╡ 2cc5b37f-bb68-41f3-8c90-4e8bea93bd9b
md"### Example 2: Means of Numerical Variables"

# ╔═╡ 176a5291-3f90-4e9f-9f5e-481976f61809
let 
	df2 = dropmissing(df)
	
	g = groupby(df2, [:species, :island, :sex])

	c = combine(g, valuecols(g) .=> mean)
end

# ╔═╡ d831df6d-9a11-4215-8638-c57c598af654
md"""
# [Tider.jl](https://github.com/TidierOrg/Tidier.jl)

!!! note "Tidyverse in Julia"
	I have not used this myself, but the Tidier.jl ecosystem in Julia is new and growing fast.  If you already are familiar with the tidyverse and are set in your ways, Tidier.jl may help you transition workflows to Julia.

	| Julia | R |
	|-------|---|
	TidierData | dplyr
	TidierPlots | ggplot2
	TidierDB | dbplyr
	TidierFiles | haven and readr
	TidierCats | forcats
	TidierDates | lubridate
	TidierStrings | stringr
	TidierText | tidytext
	TidierVest | rvest

	- `using Tidier` will load all of the TidierX packages.
	- Due to R's [nonstandard evaluation](https://adv-r.hadley.nz/metaprogramming.html), some tidyverse functions are macros in Tidier.

"""

# ╔═╡ dc3152aa-2ae7-4c1a-8813-ecd0b4b64314
md"""
# (De)Serialization

!!! note "Serialization"
	If you want to save Julia data to disk to use in a future Julia session, you can use the **Serialization** standard library.  The downside is that you need to make sure you have the correct dependencies loaded in the new session.

	---

	In the example below, `deserialize` will only work if Julia already knows what the `Thing` struct is.
"""

# ╔═╡ da94e5de-4326-4b3b-aae4-e3d944a454de
let 
	file = tempname()
	
	t = Thing(3, "four")

	# Save to disk 
	serialize(file, t)

	# Load it back
	deserialize(file)
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
Cobweb = "ec354790-cf28-43e8-bb59-b484409b7bad"
DBInterface = "a10d1c49-ce27-4219-8d33-6db1a4562965"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
JSON3 = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
PlotlyLight = "ca7969ec-10b3-423e-8d99-40f33abb42bf"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
SQLite = "0aa819cd-b072-5ff4-a722-6bc24af294d9"
Serialization = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
CSV = "~0.10.14"
Cobweb = "~0.6.1"
DBInterface = "~2.6.1"
DataFrames = "~1.6.1"
HTTP = "~1.10.8"
JSON3 = "~1.14.0"
PlotlyLight = "~0.9.1"
PlutoUI = "~0.7.59"
SQLite = "~1.6.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.4"
manifest_format = "2.0"
project_hash = "9c8aa411bdcd484ad4a6931af126431374e54d4a"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "2dc09997850d68179b69dafb58ae806167a32b1b"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.8"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "PrecompileTools", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "6c834533dc1fabd820c1db03c839bf97e45a3fab"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.14"

[[deps.Cobweb]]
deps = ["DefaultApplication", "OrderedCollections", "Scratch"]
git-tree-sha1 = "1d38f9c609b1d8b33319911b4f016da29e33a776"
uuid = "ec354790-cf28-43e8-bb59-b484409b7bad"
version = "0.6.1"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "59939d8a997469ee05c4b4944560a820f9ba0d73"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.4"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "b1c55339b7c6c350ee89f2c1604299660525b248"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.15.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "6cbbd4d241d7e6579ab354737f4dd95ca43946e1"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.4.1"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DBInterface]]
git-tree-sha1 = "a444404b3f94deaa43ca2a58e18153a82695282b"
uuid = "a10d1c49-ce27-4219-8d33-6db1a4562965"
version = "2.6.1"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "04c738083f29f86e62c8afc341f0967d8717bdb8"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.6.1"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DefaultApplication]]
deps = ["InteractiveUtils"]
git-tree-sha1 = "c0dfa5a35710a193d83f03124356eef3386688fc"
uuid = "3f0dd361-4fe0-5fc6-8523-80b14ec94d85"
version = "1.1.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EasyConfig]]
deps = ["JSON3", "OrderedCollections", "StructTypes"]
git-tree-sha1 = "11fa8ecd53631b01a2af60e16795f8b4731eb391"
uuid = "acab07b0-f158-46d4-8913-50acef6d41fe"
version = "0.1.16"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "dcb08a0d93ec0b1cdc4af184b26b591e9695423a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.10"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "9f00e42f8d99fdde64d40c8ea5d14269a2e2c1aa"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.21"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "d1d712be3164d61d1fb98e7ce9bcbc6cc06b45ed"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.8"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "8b72179abc660bfab5e28472e019392b97d0985c"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.4"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "PrecompileTools", "StructTypes", "UUIDs"]
git-tree-sha1 = "eb3edce0ed4fa32f75a0a11217433c31d56bd48b"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.14.0"

    [deps.JSON3.extensions]
    JSON3ArrowExt = ["ArrowTypes"]

    [deps.JSON3.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"

[[deps.LaTeXStrings]]
git-tree-sha1 = "50901ebc375ed41dbf8058da26f9de442febbbec"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.6.4+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "c1dd6d7978c12545b4179fb6153b9250c96b0075"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.3"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+4"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "38cb508d080d21dc1128f7fb04f20387ed4c0af4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a12e56c72edee3ce6b96667745e6cbbe5498f200"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.23+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PlotlyLight]]
deps = ["Artifacts", "Cobweb", "Downloads", "EasyConfig", "JSON3", "REPL", "Random", "StructTypes"]
git-tree-sha1 = "5684d34d28ca87ef546a6cb9646d53c13f93a8ea"
uuid = "ca7969ec-10b3-423e-8d99-40f33abb42bf"
version = "0.9.1"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "ab55ee1510ad2af0ff674dbcced5e94921f867a9"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.59"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "66b20dd35966a748321d3b2537c4584cf40387c7"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.3.2"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SQLite]]
deps = ["DBInterface", "Random", "SQLite_jll", "Serialization", "Tables", "WeakRefStrings"]
git-tree-sha1 = "38b82dbc52b7db40bea182688c7a1103d06948a4"
uuid = "0aa819cd-b072-5ff4-a722-6bc24af294d9"
version = "1.6.1"

[[deps.SQLite_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "004fffbe2711abdc7263a980bbb1af9620781dd9"
uuid = "76ed43ae-9a5d-5a62-8c75-30186b810ce8"
version = "3.45.3+0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "90b4f68892337554d31cdcdbe19e48989f26c7e6"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.3"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a04cabe79c5f01f4d723cc6704070ada0b9d46d5"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.4"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "ca4bccb03acf9faaf4137a9abc1881ed1841aa70"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.10.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "cb76cf677714c095e535e3501ac7954732aeea2d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
git-tree-sha1 = "a947ea21087caba0a798c5e494d0bb78e3a1a3a0"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.10.9"
weakdeps = ["Random", "Test"]

    [deps.TranscodingStreams.extensions]
    TestExt = ["Test", "Random"]

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.WorkerUtilities]]
git-tree-sha1 = "cd1659ba0d57b71a464a29e64dbc67cfe83d54e7"
uuid = "76eceee3-57b5-4d4a-8e66-0e911cebbf60"
version = "1.6.1"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╟─829bd170-07d7-11ef-2c11-494482da4d69
# ╟─fa5320e4-d694-47ff-951a-29a1f5be2256
# ╠═8e05339e-938f-42ed-9028-8d68f6f85107
# ╠═9ffdb7e7-7951-4ea1-a83b-47bc9609b947
# ╠═bdb6766f-c39f-4978-b866-9a303394d8a3
# ╠═c11d767f-b595-4f0d-8b82-a839c3695360
# ╠═8bcddeeb-a6f2-4546-b56e-3056f2edc91e
# ╠═65935cfe-61ac-4cf5-a2a8-dd33a40565ab
# ╠═d21d3e07-2cd9-4be9-b331-bffca112bc79
# ╠═c0d90583-c612-4337-86cc-b59a8d92a7a8
# ╠═39841f5b-332e-4b42-ae13-b276a9c76de3
# ╠═6769ecc2-923a-4364-af6d-0ed3a3d2db9e
# ╠═07aa119e-20c8-43f5-aec8-3f186397a654
# ╠═46cd8c2d-4691-4d22-aa0f-f89497a30bee
# ╠═3b1235b6-8bba-4c95-9c42-bbaf033871b2
# ╠═c3f5bbc7-4dae-4408-a293-180ec22b978d
# ╠═c31adb44-ebc5-414f-83fa-70ab458193ac
# ╠═a0b74bac-f53a-4cfe-9303-b6bd6d3e9bc6
# ╠═d65f62ca-52cf-4bc1-bdb2-db45e2010360
# ╠═adf74af9-241e-4d1e-a0f2-8d889964a5a9
# ╠═a2adff69-2e57-4601-b553-e0d2a1eeb1bc
# ╠═15aecd6a-c8d4-4510-bc15-01dc60336da0
# ╟─56dc1e5b-6190-44d0-9dd5-c5b43eb048d8
# ╠═36fca49a-34ee-46e5-948f-c57bbb7b603c
# ╠═7986066c-4bdd-459b-90b3-4b7a642e7888
# ╠═90012400-b655-4b11-810c-13e880b1a0cc
# ╠═76a9e7ba-a1a1-45f0-a95e-f7975b5095ab
# ╠═930cf068-4b2b-4baf-b485-6ece1cc02364
# ╠═af72a6a5-0bc6-4287-be83-86c546e3baf3
# ╠═f9f40a9f-b77c-4278-804f-da1605d57ffa
# ╠═63afafdb-4583-4558-9d0e-2c55b34c0122
# ╠═f1d96853-4bf2-457a-ae4e-c01eacccfafb
# ╠═7e3d8422-9e75-4bad-9787-0a97604294b2
# ╠═617d2deb-0d7d-43e5-b24a-f1e863db0826
# ╠═d2b47884-a0e2-4d63-bdae-e1c549dca8fe
# ╠═cc575e83-d226-4a0f-86f3-f2499b91e72c
# ╠═5f2deb6f-9b5f-4ed4-b661-5e55f657a70b
# ╠═bf06fd7f-1248-4897-82b5-a03af9582b90
# ╠═876e4065-3741-4144-b35b-871a1554ada1
# ╠═7be196e9-ec18-486f-a8fa-116ea451468b
# ╠═aab3524d-eafb-4bad-aaca-0821f2d02476
# ╠═3db58a19-b3e7-4b06-a091-caccb3733d42
# ╠═530ec008-a40b-4b63-8d1d-5967866594d5
# ╠═722456c8-b7c8-4500-9d7b-9b0ca019bc58
# ╠═9b314950-e47d-4c16-9e52-0a02235b205b
# ╠═d3032cf2-4870-4f0e-976e-78d33a375244
# ╠═d459bbba-f5f4-4616-b51c-312f235fd255
# ╠═8ecc4873-b6af-4bfe-bb18-418ec9937381
# ╟─045a19ee-6a22-4446-a378-2e8485293357
# ╠═392de5f3-da48-4f75-9295-95feb90954ac
# ╠═a4e12565-2736-4b67-ac74-9a3b25c4605b
# ╠═e010ba8a-fd49-4621-a159-5cdef2a1e6c1
# ╠═bdc04231-69d9-4c23-9266-60996714c388
# ╠═a97bf75f-7c3b-43ed-aee0-001eeb347668
# ╠═2cc5b37f-bb68-41f3-8c90-4e8bea93bd9b
# ╠═2d9c9bf3-b62e-4f08-8d25-43847037a6b9
# ╠═176a5291-3f90-4e9f-9f5e-481976f61809
# ╠═d831df6d-9a11-4215-8638-c57c598af654
# ╠═dc3152aa-2ae7-4c1a-8813-ecd0b4b64314
# ╠═760218bd-b5ae-4b95-8f53-430d484d1d29
# ╠═da94e5de-4326-4b3b-aae4-e3d944a454de
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
