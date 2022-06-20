### A Pluto.jl notebook ###
# v0.19.8

using Markdown
using InteractiveUtils

# ╔═╡ e324b2c4-ecbe-11ec-36a3-d9993d2df125
begin 
	using Pkg
	Pkg.activate(@__DIR__)
	using PlutoUI
	

	md"""
	# Reading Data

	- In this section, we'll learn how to get data into Julia using the following packages:
	  - **CSV**
	  - **DataFrames**

	$(PlutoUI.TableOfContents())
	"""
end

# ╔═╡ 9fc4d983-9142-473c-9913-de758e658b43
using CSV

# ╔═╡ 764fb877-9a29-4cee-a5b0-326e5e9572ce
md"""
# Reading Data

- In this section, we'll learn how to get data into Julia using the following packages:
  - **CSV**
  - **DataFrames**
"""

# ╔═╡ 52589343-41fc-4443-b5a9-598d106695dd
md"""
# `read`-ing data

- Example: Iris dataset
"""

# ╔═╡ db7ba406-5920-4522-91ef-b82e700c73ff
iris_url = "https://gist.githubusercontent.com/joshday/df7bdaa1d58b398592e7656395de6335/raw/5a1c83f498f8ca7e25ff2372340e44b3389be9b1/iris.csv";

# ╔═╡ 5b76367b-3e0a-4be6-adac-7990f32ebb5e
iris_path = download(iris_url);

# ╔═╡ c963b160-e082-4d8d-b94e-6aa8abd7a1ad
md"""
## `read(file)`

- Returns the raw bytes in the file.
"""

# ╔═╡ 379ea446-93ee-4bc8-a140-13f2143c72fc
read(iris_path)

# ╔═╡ 85ace92c-f47e-4c18-b859-95ae2afe6a20
md"""
## `read(file, T)`

- Returns the file interpreted as type `T`.
"""

# ╔═╡ a4351f14-5b95-44d5-94ee-11dadd368dd9
read(iris_path, String)

# ╔═╡ 7cd94d53-082a-4a26-bf8f-031ce5e844df
md"""
# Reading CSVs
"""

# ╔═╡ Cell order:
# ╠═e324b2c4-ecbe-11ec-36a3-d9993d2df125
# ╠═764fb877-9a29-4cee-a5b0-326e5e9572ce
# ╟─52589343-41fc-4443-b5a9-598d106695dd
# ╠═db7ba406-5920-4522-91ef-b82e700c73ff
# ╠═5b76367b-3e0a-4be6-adac-7990f32ebb5e
# ╟─c963b160-e082-4d8d-b94e-6aa8abd7a1ad
# ╠═379ea446-93ee-4bc8-a140-13f2143c72fc
# ╟─85ace92c-f47e-4c18-b859-95ae2afe6a20
# ╠═a4351f14-5b95-44d5-94ee-11dadd368dd9
# ╟─7cd94d53-082a-4a26-bf8f-031ce5e844df
# ╠═9fc4d983-9142-473c-9913-de758e658b43
