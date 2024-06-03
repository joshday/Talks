### A Pluto.jl notebook ###
# v0.19.41

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

# ╔═╡ 5bf87bd0-b90f-4c42-8558-8d4dd5c3303d
begin
	using Cobweb: Cobweb, h
	using PlutoUI
	img(src, style="") = h.img(; src, style="border-radius:8px;$style")
	md"""
	(notebook setup)
	$(PlutoUI.TableOfContents())
	$(HTML("<style>h1 { padding-top: 200px; }</style>"))
	$(HTML("<style>h2 { padding-top: 100px; }</style>"))
	"""
end

# ╔═╡ f2db2ea4-b450-4ca2-b307-25a4e37f3af6
using PlotlyLight  # This will install the package if needed

# ╔═╡ 7de5c628-d8c4-49e1-9e20-b60a414615e5
md"""

$(html"<img style='display:block; margin:auto' src='https://raw.githubusercontent.com/JuliaLang/julia-logo-graphics/master/images/julia-logo-dark.svg' width=300px>")

# SDSS 2024: Julia for Data Science

- When: Tue, Jun 4, 2024 (1:30 PM - 5:30 PM)
- Speaker: **Dr. Josh Day**, *Senior Research Scientist at JuliaHub*

$(html"<img style='display:block; margin:auto; padding-bottom:20px;' src='https://juliahub.com/assets/img/juliahub-color-logo.svg' width=300px>")
"""

# ╔═╡ 57b341ff-6792-442d-8953-343961747087
md"""
!!! info "About Josh"

	I'm a Statistics PhD (NC State) who primarily does R&D/innovative software for government customers working within restricted computing environments.  I maintain many open source Julia packages, notably [OnlineStats](https://github.com/joshday/OnlineStats.jl), a package of parallelizable on-line algorithms for statistics and data viz.

	---

	- Feel free to ask me questions after the course!  
	- My email address is **emailjoshday@gmail.com**
"""

# ╔═╡ 55229341-1bbb-4b3b-9b38-bd50484bfa84
md"""
!!! info "About the Course"

	- Course Materials have been developed as [Pluto Notebooks](https://plutojl.org).
	- All materials avaiable in the GitHub repo: [https://github.com/joshday/Talks](https://github.com/joshday/Talks).
"""

# ╔═╡ 0d9344a8-3812-4dae-8d5d-813dfd9eae1e
md"""
!!! info ""
	To begin, we will: 
	1. Install Julia.
	2. Install Pluto.
	3. Discuss programming environments.
"""

# ╔═╡ c51b88b6-a304-4fd8-878a-337547334099
md"""
# Resources

- [Modern Julia Workflows](https://modernjuliaworkflows.github.io) (Thorough "getting started" blog posts)
- [Julia Cheat Sheet](https://cheatsheet.juliadocs.org/)
- [juliadatascience.io](https://juliadatascience.io/)
"""

# ╔═╡ e5b25933-b0b6-4e6e-ac7b-8f6eb74203ae
md"""
# Course Outline

1. Introduction
2. Why Julia
3. Julia Basics
4. Plotting
5. Data
6. Modeling
"""

# ╔═╡ 2bd06863-d4f9-48f1-9dd3-12269f5cc4be
md"# Course Setup"

# ╔═╡ f77b1461-9eab-4678-b632-6b21a1349bc5
md"""
## 1) Installing Julia

- Instructions from [https://julialang.org/downloads/](https://julialang.org/downloads/)
- Simply copy/paste the `curl`/`winget` command into a terminal.


#### Mac/Linux:
```
curl -fsSL https://install.julialang.org | sh
```

#### Windows:
```
winget install julia -s msstore
```

#### What This Does

1. **Adds the `julia` command** to start the Julia REPL (Read-Eval-Print-Loop).
2. **Adds the `juliaup` command** for managing Julia versions.  Whenever there is a new Julia release, you'll see some info printed out about how to update.

#### Test it Out

- Try typing `julia` (followed by Enter/Return) in your terminal.
"""

# ╔═╡ ca436b1c-b43a-4386-8b35-50535dcd9fa8
md"""
## 2) Installing Pluto.jl

1. Type `julia` in your terminal to start the Julia REPL.
2. Press `]` to enter the **pkg** REPL mode.
3. Type `add Pluto` and hit enter.

Your Julia REPL should look something like this:

```
julia>

# Press `]` to enter "pkg" mode:

(@v1.10) pkg> add Pluto
   Resolving package versions...
    Updating `/.../Project.toml`
  [c3e4b0f8] + Pluto v0.19.40
    Updating `/.../Manifest.toml`
  [d1d4a3ce] + BitFlags v0.1.8
  [944b1d66] + CodecZlib v0.7.4
  [f0e56b4a] + ConcurrentUtilities v2.4.1
  [5218b696] + Configurations v0.17.6
    ⋮
```

"""

# ╔═╡ a25dcfc4-66b0-4f88-8a4b-8ad1f2ada920
md"""
# What is Pluto?

Pluto is a *reactive* notebook environment that offers:

- **Interactivity** (widgets, etc.).
- **Reproducibility** (built-in package manager).
  - As a course instructor, I have no fear that everyone can get up and running quickly.
- **No hidden state** (No need to click "restart and run all").

!!! info "Cell Output"
	One thing you'll quickly notice is that cell output is *above* the cell, rather than below as with Jupyter notebooks.
"""

# ╔═╡ 7fb6df93-8c53-433c-895c-010e2ad23fef
md"## Reactivity/Interactivity:"

# ╔═╡ 15d0df82-9436-497a-84e6-450db2a18bf1
x = 15  # Change this value...

# ╔═╡ d17dd821-d99c-422f-a693-54199a2ddc2b
x + 10  # ...and this updates automatically

# ╔═╡ e1905587-ec4f-457b-902b-421ad9194fb6
md"""### Binding HTML input to Julia variables"""

# ╔═╡ 2b828b66-fa42-4ca7-b8ea-de4d83c6ede1
@bind slider PlutoUI.Slider(1:20, show_value=true)

# ╔═╡ bacdcea9-1d26-448b-9ffa-9040aa0eff04
slider + x  # Updates based on Slider value

# ╔═╡ 7c13531d-b03b-4afb-8996-d1d73c328930
md"""
!!! note "What can I @bind?"
	Any type of HTML `<input>`.

	Note that `PlutoUI.Slider(...)` is simply a more convenient way of writing HTML.  We can inspect how something gets inserted into the page via `repr("text/html", x)`.

	```julia
	repr("text/html", PlutoUI.Slider(1:20, show_value=true))
	# "<input type='range' min='1' step='1' max='20' value='1' oninput=''>"
	```
"""

# ╔═╡ f5bd5b48-71f9-4fdd-8ad6-7fa3d1eee70e
input_types = ["button", "checkbox", "color", "date", "datetime-local", "email", "file", "hidden", "image", "month", "number", "password", "radio", "range", "reset", "search", "submit", "tel", "text", "time", "url", "week"]

# ╔═╡ 0491563b-aa59-42d8-bfc5-793f2bc7f417
@bind input_type Select(input_types)

# ╔═╡ 97520765-505a-4409-8d24-29b36a210ff7
@bind bindvar HTML("<input type='$input_type'>")

# ╔═╡ cfb3c98c-84fe-4fbe-a1a0-9e8a32ec2294
bindvar

# ╔═╡ 25503103-d259-447b-a3a9-a817743d8508
md"""
## Reproducibility:
"""

# ╔═╡ ecd48624-5a93-422b-b5b8-07d9b527936d
plot.bar(y=1:10)

# ╔═╡ 0a755c64-3a31-45ab-8056-55d66e2f1e46
md"""## No Hidden State
- The state of the notebook must be completely determined by the underlying notebook file (which is a normal text `.jl` file).
- Because of this, Pluto.jl won't let you do certain things.
"""

# ╔═╡ 9bb0d697-2575-4840-ac5d-096eed487f34
md"### Multiple Definitions of Same Variable"

# ╔═╡ 460ffb7d-8fe1-40d6-814e-a468890b7722
md"""
## A More Advanced Example

!!! note ""
	Pluto is super hackable with a little bit of HTML/Javascript knowledge.

	For example, you can make non-inputs look like inputs.  Open the code in the cell below to see how.
"""

# ╔═╡ d9e2aa24-af11-4d5a-8fc5-0b128cf69e74
@bind loc HTML("""
<span>
<button>Share Location</button>

<script>
	const span = currentScript.parentElement
	const button = span.querySelector("button")

	let lat = null
	let lon = null

	const success = (pos) => {
		lat = pos.coords.latitude
		lon = pos.coords.longitude
	}

	const error = (err) => {
		alert("Couldn't get location!")
	}

	button.addEventListener("click", (e) => {
		navigator.geolocation.getCurrentPosition(success, error)
		span.value = { lat: lat, lon: lon}
		span.dispatchEvent(new CustomEvent("input"))
	})

	span.value = { lat: lat, lon: lon}
</script>
</span>
""")

# ╔═╡ 8d4fb0c6-fbaa-4cbc-86fd-86cb322bbe10
if !isnothing(loc["lat"])
	latlon = (;lat=loc["lat"], lon=loc["lon"])
	p = plot.scattermapbox(; map(collect, latlon)..., hovertext=["You are Here!"],
		marker=(;size=15))
	p.layout.mapbox = (;center = latlon, zoom=7, style="open-street-map")
	p.layout.margin = (l=0, r=0, t=0, b=0)
	p
else
	@info "Click `Share Location` to plot your location on a map!"
end

# ╔═╡ 5fbdbcc2-b902-4200-bafd-eb1c40bf7458
md"""
# Coding Environments

Most people write their Julia code in one of the following environments:

- The REPL
- Pluto Notebooks
- Jupyter Notebooks
- VSCode

### Results of 2023 Julia Users and Developers Survey

$(img("https://github.com/joshday/Talks/assets/8075494/0d56340e-5f91-4775-af1f-cc7095305a64"))
"""

# ╔═╡ 2d2953a5-5a8f-4c9d-a900-ea00f99243db
md"""
## The REPL

The first place you're likely to write Julia is in the REPL (Read-Eval-Print Loop).

!!! note "When should I use the REPL?"
	- ✅ For quick, interactive work.
	- ✅ Installing packages.
	- ✅ Running a script, e.g. `include("script.jl")`.

!!! note "Installing the REPL"
	The REPL is in Julia's [Standard Library](https://juliadatascience.io/standardlibrary).  You don't need to install anything extra.

	That being said, [OhMyREPL.jl](https://kristofferc.github.io/OhMyREPL.jl/latest/) provides syntax highlighting and bracket matching in the REPL.

!!! note "Starting the REPL"
	If you've installed Julia with `juliaup`, simply type `julia` into your terminal.
"""

# ╔═╡ 2f474499-c8a3-4077-804a-47b1f2f2ef1e
img("https://github.com/joshday/Talks/assets/8075494/f2c9f3bf-deb9-4aa8-89ad-71570e0d52bc")

# ╔═╡ 5a5caa11-4e45-4516-bd2c-1356c779dc60
md"- OhMyREPL adds color:"

# ╔═╡ 2ec47abc-cdd5-4079-9014-f2ae23380979
img("https://i.imgur.com/wtR0ASD.png", "width:500px")

# ╔═╡ 5ba4a710-819e-40f7-bbc3-025930a88921
md"""
## Pluto Notebooks

What you're looking at right now!  

!!! note "When should I use Pluto?"
	- ✅ Quick, interactive work.
	- ✅ Iterative development (I really like it plotting).
	- ✅ Presenting code alongside "content".
	- ✅ Creating lightweight GUIs.

!!! note "Installing Pluto"
	Simply `import Pkg; Pkg.add("Pluto")` (or `add Pluto` within the `pkg` REPL mode).

!!! note "Starting Pluto"
	```julia
	using Pluto

	Pluto.run()
	```
"""

# ╔═╡ 891d5231-7306-487f-99ac-3f53dbf3a64e
println("Hello, world!")

# ╔═╡ 482a2ebb-1ef3-4b01-8ffc-44d974f91eae
md"""
## Jupyter Notebooks via IJulia.jl

A Language-agnostic notebook environment.  Pros and cons:

!!! note "When should I use Jupyter?"
	- ✅ Working in a polyglot team/project.
	- ✅ You or your audience is more familiar with it than Pluto.

!!! note "Installing IJulia"
	```julia
	using Pkg

	Pkg.add("IJulia")
	```

!!! note "Launching Jupyter notebook"
	```julia
	using IJulia

	notebook()
	```
"""

# ╔═╡ afd6eaeb-ca9d-45a6-8578-18e676ddcfb8
img("https://github.com/joshday/Talks/assets/8075494/83ef5d3a-c128-4ce3-bc63-2f4bbdedbb65")

# ╔═╡ 28871cd5-21be-4c5b-83fc-a6f11cf5e215
md"""
## VS Code

A free, open source code editor developed by Microsoft.  

Note that in 2023, 78% of Julia User & Developer Survey respondents said they use VS Code [(Survey results PDF)](https://julialang.org/assets/2023-julia-user-developer-survey.pdf).

!!! note "When should I use VS Code?"
	- ✅ "Serious development" with a linter, debugger, git integration, etc.
	- ✅ Writing scripts.
	- ✅ Developing packages.
	- ✅ Making open source contributions.

!!! note "Installing the  [Julia for VSCode extension]"
	Search for "Julia" under extensions and click "Install".  

	See [https://www.julia-vscode.org](https://www.julia-vscode.org) for more info.

!!! note "Launching Julia for VSCode"
	If the extensions is enabled, it will be available when VSCode launches.  

	There is a lot of functionality here.  See the link above or search for "Julia" in the command palette.
"""

# ╔═╡ 0e870fd9-3b98-4e41-91d5-9a2f4f4c72b0
md"# Next: Why Julia?"

# ╔═╡ 190356c3-ea1a-4da6-b878-3dd284ef9c3b
# ╠═╡ disabled = true
#=╠═╡
var = 2
  ╠═╡ =#

# ╔═╡ 5342fac8-464e-4724-950f-fff9f3156cc7
#=╠═╡
var = 1
  ╠═╡ =#

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Cobweb = "ec354790-cf28-43e8-bb59-b484409b7bad"
PlotlyLight = "ca7969ec-10b3-423e-8d99-40f33abb42bf"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
Cobweb = "~0.6.1"
PlotlyLight = "~0.8.2"
PlutoUI = "~0.7.58"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.3"
manifest_format = "2.0"
project_hash = "7d10859742e5f2609cc0aedcc3795cd9c655b79f"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "0f748c81756f2e5e6854298f11ad8b2dfae6911a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Cobweb]]
deps = ["DefaultApplication", "OrderedCollections", "Scratch"]
git-tree-sha1 = "1d38f9c609b1d8b33319911b4f016da29e33a776"
uuid = "ec354790-cf28-43e8-bb59-b484409b7bad"
version = "0.6.1"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

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

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

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

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

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

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

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
git-tree-sha1 = "62c97c14bedc0797ef730ffb2177e869c7dec621"
uuid = "ca7969ec-10b3-423e-8d99-40f33abb42bf"
version = "0.8.2"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "71a22244e352aa8c5f0f2adde4150f62368a3f2e"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.58"

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

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

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

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

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
# ╟─5bf87bd0-b90f-4c42-8558-8d4dd5c3303d
# ╟─7de5c628-d8c4-49e1-9e20-b60a414615e5
# ╟─57b341ff-6792-442d-8953-343961747087
# ╟─55229341-1bbb-4b3b-9b38-bd50484bfa84
# ╟─0d9344a8-3812-4dae-8d5d-813dfd9eae1e
# ╟─c51b88b6-a304-4fd8-878a-337547334099
# ╟─e5b25933-b0b6-4e6e-ac7b-8f6eb74203ae
# ╟─2bd06863-d4f9-48f1-9dd3-12269f5cc4be
# ╟─f77b1461-9eab-4678-b632-6b21a1349bc5
# ╟─ca436b1c-b43a-4386-8b35-50535dcd9fa8
# ╟─a25dcfc4-66b0-4f88-8a4b-8ad1f2ada920
# ╟─7fb6df93-8c53-433c-895c-010e2ad23fef
# ╠═15d0df82-9436-497a-84e6-450db2a18bf1
# ╠═d17dd821-d99c-422f-a693-54199a2ddc2b
# ╟─e1905587-ec4f-457b-902b-421ad9194fb6
# ╠═2b828b66-fa42-4ca7-b8ea-de4d83c6ede1
# ╠═bacdcea9-1d26-448b-9ffa-9040aa0eff04
# ╟─7c13531d-b03b-4afb-8996-d1d73c328930
# ╟─f5bd5b48-71f9-4fdd-8ad6-7fa3d1eee70e
# ╠═0491563b-aa59-42d8-bfc5-793f2bc7f417
# ╠═97520765-505a-4409-8d24-29b36a210ff7
# ╠═cfb3c98c-84fe-4fbe-a1a0-9e8a32ec2294
# ╟─25503103-d259-447b-a3a9-a817743d8508
# ╠═f2db2ea4-b450-4ca2-b307-25a4e37f3af6
# ╠═ecd48624-5a93-422b-b5b8-07d9b527936d
# ╟─0a755c64-3a31-45ab-8056-55d66e2f1e46
# ╟─9bb0d697-2575-4840-ac5d-096eed487f34
# ╠═5342fac8-464e-4724-950f-fff9f3156cc7
# ╠═190356c3-ea1a-4da6-b878-3dd284ef9c3b
# ╟─460ffb7d-8fe1-40d6-814e-a468890b7722
# ╟─d9e2aa24-af11-4d5a-8fc5-0b128cf69e74
# ╟─8d4fb0c6-fbaa-4cbc-86fd-86cb322bbe10
# ╟─5fbdbcc2-b902-4200-bafd-eb1c40bf7458
# ╟─2d2953a5-5a8f-4c9d-a900-ea00f99243db
# ╟─2f474499-c8a3-4077-804a-47b1f2f2ef1e
# ╟─5a5caa11-4e45-4516-bd2c-1356c779dc60
# ╟─2ec47abc-cdd5-4079-9014-f2ae23380979
# ╟─5ba4a710-819e-40f7-bbc3-025930a88921
# ╠═891d5231-7306-487f-99ac-3f53dbf3a64e
# ╟─482a2ebb-1ef3-4b01-8ffc-44d974f91eae
# ╟─afd6eaeb-ca9d-45a6-8578-18e676ddcfb8
# ╟─28871cd5-21be-4c5b-83fc-a6f11cf5e215
# ╟─0e870fd9-3b98-4e41-91d5-9a2f4f4c72b0
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
