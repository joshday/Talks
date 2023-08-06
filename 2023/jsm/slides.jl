### A Pluto.jl notebook ###
# v0.19.27

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

# ╔═╡ daebeaf7-b7a5-4a29-afd5-19b57a0f37f7
let
	using AbstractTrees
	
	# In general, don't do this!
	# Piracy is defining a method on a type when you "own" neither.
	AbstractTrees.children(T::DataType) = subtypes(T)
	print_tree(Real)
end

# ╔═╡ f611d61e-30a1-11ee-3119-99255be33a07
begin
	
	using PlutoUI
	using PlotlyLight
	using Cobweb
	using Cobweb: h
	using EasyConfig
	using Distributions
	using RCall
	using DataFrames
	using PlotlyLight
	using StatsModels
	using CSV
	using GLM
	
	struct Foldable
	    title::String
	    content
	end

	vspace= h.div(style="height:20vh")
	
	function Base.show(io, mime::MIME"text/html", fld::Foldable)
	    write(io,"<details><summary>$(fld.title)</summary><p>")
	    show(io, mime, fld.content)
	    write(io,"</p></details>")
	end

	struct TwoColumn
	    left
	    right
		percent_left::Int
	end
	
	function Base.show(io, mime::MIME"text/html", tc::TwoColumn)
	    write(io, """<div style="display: flex;"><div style="flex: $(tc.percent_left)%;">""")
	    show(io, mime, tc.left)
	    write(io, """</div><div style="flex: $(100-tc.percent_left)%;">""")
	    show(io, mime, tc.right)
	    write(io, """</div></div>""")
	end

	md"""
	$(h.div(style="height:90vh"))
	(setup) 
	$(PlutoUI.TableOfContents())
	$(html"
		<style>
		pluto-log-dot.Stdout {
			background: black
		}
		pluto-log-dot.Stdout:after {
			background: black
		}
		</style>
		")
	"""
end

# ╔═╡ 28c981d6-30ab-45fd-bc5f-7649eb371894
html"<button onclick='present()'>present</button>"

# ╔═╡ 4c4b2682-d008-416e-8898-85fd2250d877
md"""

$(html"<img style='display:block; margin:auto' src='https://raw.githubusercontent.com/JuliaLang/julia-logo-graphics/master/images/julia-logo-dark.svg' width=300px>")

# Julia for Computational Statisticans

- Dr. Josh Day, *Senior Research Scientist at JuliaHub*

> I'm a Statistics PhD (NC State) who now primarily does R&D/innovative software design for government customers.  I maintain many open source Julia packages, most notably [OnlineStats](https://github.com/joshday/OnlineStats.jl), a package of parallelizable on-line algorithms for statistics.


$(html"<img style='display:block; margin:auto' src='https://juliahub.com/assets/img/juliahub-color-logo.svg' width=300px>")
"""

# ╔═╡ 1da9ab32-7f8e-4ffb-82c9-b584e33e522c
md"""
# This Talk

1. Overview of Julia
2. Learnings from R
3. Using R from Julia
4. Should you try Julia?

- Pluto notebook available at [https://github.com/joshday/Talks](https://github.com/joshday/Talks)

#### Keep this in mind: The Sapir-Whorf Hypothesis

> The structure of a language influences its speakers' worldview or cognition, and thus individuals' languages determine or shape their perceptions of the world.

- [https://en.wikipedia.org/wiki/Linguistic_relativity](https://en.wikipedia.org/wiki/Linguistic_relativity)

!!! info "The Programming Language version of this:"
	Your language influences/determines how you solve problems.

	- How does R/Python affect how you approach problems/write code?

	- How would you approach problems in Julia?
"""

# ╔═╡ ec35cc71-9656-4a4f-b854-d69b3abc3851
md"""
# Julia Highlights
"""

# ╔═╡ 8fcfaeca-eab8-4e30-ac80-5bf77e4d8f97
md"""
## 1. Performance

![](https://julialang.org/assets/images/benchmarks.svg)

!!! info "Can I take what makes Julia fast and bolt it onto R/Python?"
	Not really.  Julia is fast because of core design decisions that work well together.
"""

# ╔═╡ 4f56158c-5e53-4dcb-a62b-6a0fb7bc6d1b
md"""
!!! success "Quick Story"
	- At my first JuliaCon (2016), I saw Doug Bates give a 10 minute lightning talk about `MixedModels.jl`.
	- He had translated a model from R to Julia that took "most of the day" to fit  in `lme4`.
	- He ran live code and fit the model in ~5 minutes during his lightning talk.
"""

# ╔═╡ be5c6bcd-fcd0-4637-ba74-3db56aa70458
md"""
## 2. Multiple Dispatch/Specialization

- Julia uses a Just-in-time (JIT) compiler (LLVM).
"""

# ╔═╡ 6db786aa-7e5f-4911-99f9-1cd5ff567698
f(x) = x + x

# ╔═╡ f2a88086-dcc1-449e-8ee2-23bb14fac992
# The JIT compiles a method specific to 64-bit Integers
@code_llvm f(1)

# ╔═╡ 3eaafd87-508f-484c-9816-9a90518b3cb0
# Similarly, the JIT compiles a method specific to double precision floats
@code_llvm f(1.0)

# ╔═╡ 3754ba52-4617-4313-bcc4-d86bd2dc10a8
md"""
!!! info "Specialized code \"for free\""
	I didn't tell Julia about the type of the input, but I still get *specialized* code.
"""

# ╔═╡ de051b5d-adaa-4d6e-a2a7-498fee248201
md"""
!!! note "Built-in vs. User-defined functions"
	- Built-in functions aren't special.  
	- There's no difference between built-in and user-defined functions.

	#### Related:

	- Most Julia packages are **100% Julia**.  This is really helpful for debugging!  
	  - `@edit f(...)` immediately opens up the file where the method `f` is defined. 
      - It's nice to see Julia under the hood and not calls to C/Fortran.
"""

# ╔═╡ 4284c6e9-2801-4e63-870f-4ebf6b9ab3d8
md"""
!!! note "Note: Dispatch and Multiple Dispatch"
    - **Dispatch** is the choice of which method to execute when a function is applied. 
	- **Multiple Dispatch** is dispatch based on the types of *all* arguments to a function.
"""

# ╔═╡ f809185e-c624-42bd-9b91-68b2dd854672
md"""
#### A more complicated example:

Finding quantiles with Newton's Method for finding roots:

$$\text{Solve for } x \text{:}\quad F_X(x) - q= 0$$

- where $F_X$ is CDF of random variable $X$.

$$x_{n+1} = x_n - \frac{F_X(x_n) - q}{F_X'(x_n)}$$

"""

# ╔═╡ 7f1be803-c01c-4223-bf63-19c5b5a4d781
function myquantile(dist, q)
    x = mean(dist)
    for i in 1:20
        x -= (cdf(dist, x) - q) / pdf(dist, x)
    end
    x
end

# ╔═╡ 4318a3e9-b33c-47aa-8a5b-10cf33a84f96
@info "Does this work?" quantile(Gamma(40,1), .5) myquantile(Gamma(40,1), .5)

# ╔═╡ e43a9b9f-369f-44a4-804f-f50b64fb49fe
md"""
Let's try a few more distributions:

$(@bind dist Select([Normal(), Gamma(5,1), Beta(7,2), nothing]))
"""

# ╔═╡ 77230db4-dfaa-4559-a054-328931a0bb56
let
	rng = .01:.01:.99
	isnothing(dist) ? nothing : Plot()(
		y=rng, x=quantile.(dist, rng), name="quantile"
	)(
		y=rng, x=myquantile.(dist, .01:.01:.99), line=(;dash="dot"),
		name="myquantile"
	)
end

# ╔═╡ 44d794c1-fa56-4d71-950d-da8c77f926ea
md"""
## 3. Type System

- Abstract types don't "exist", but define a set.
- Concrete types "exist".

!!! note "Types: Think Sets"
	Using an abstract type as a type annotation says "this function works with any type from this set"

	```julia
	f(x::Integer) = x + 1

	f(1.0)  # error, because 1.0 isa Float64 (not in set of Integers)

	g(x::Real) = x + 1 

	g(1.0)  # success!
	```
"""

# ╔═╡ a724cfe9-9b7c-43c8-80a0-ce87325cf327
md"""
!!! info "Type Annotations"
	*Type Annotations* do not affect performance. e.g.

	```julia
	f(x::Number) = x + x
	```

	They are used for two things:
	
	1. **Validating user inputs.** E.g. You never need to do this:
	```julia
		function f(x)
			x isa String || error("x should be a string")
		end
	```
	2. **(Multiple) Dispatch**.  E.g.
	```julia
	half(x::Number) = x / 2 

    half(x) = x[1:floor(Int, length(x) / 2)]
	```
"""

# ╔═╡ 24a31b5d-7309-4774-8adb-acb6d462525c
let
	half(x::Number) = x / 2 

    half(x) = x[1:floor(Int, length(x) / 2)]

	@info "Dispatch example with half" half(1) half(5//5) half(1 + 1im) half("ABCDEFG") half([1,2,3,4]) half(1:4) half((1,2,3,4))
end

# ╔═╡ 9f45fc0d-33ee-4e43-813c-ddc25ac755f7
md"""
## 4. Broadcasting

- Make operations more explicit at the cost of one character.

```julia
x = randn(100)

# There's no mathematical definition of the absolute value of a vector.
abs(x)  # Error

# "broadcast" `abs` to each element of `x`
abs.(x)  
```
- Chain broadcasts to avoid temporary copies -> Big performance gains!
"""

# ╔═╡ 27f7a89f-de60-4753-8fd6-73964ae3c600
let 
	x = randn(100)

	y = abs.(sin.(sqrt.(x .+ 10)))

	# What R does with: y = abs(sin(sqrt(x + 10)))

	# Essentially, R is doing:
	temp1 = x .+ 10
	temp2 = sqrt.(temp1)
	temp3 = sin.(temp2)
	y = abs.(temp3)
end

# ╔═╡ 4a9081f9-df1c-4ed1-a38f-64af8b1c527f
md"""
## 5. Metaprogramming/Macros

!!! note "What is a Macro?"
	A function of an *expression*.  Macros can change an expression before it gets evaluated.

	- Julia expressions are represented in Julia.

	```julia
	@mymacro 1 + 2
	```

	- `@mymacro`'s input here is `Expr(:call, :+, 1, 2)`
"""

# ╔═╡ 7df066ec-2d70-44b9-809c-3d90bc765890
dump(Meta.parse("1 + 1"))

# ╔═╡ c50b6262-77ab-486b-8b86-b61ed07e6f50
macro mymacro(ex)
	ex.args[end] = 100
	return ex
end

# ╔═╡ e7d3f396-a446-485e-9022-77f7ddc73472
@mymacro 1 + 2

# ╔═╡ 62c23af8-c3b6-4226-a665-17d40d126c01
macro change_op_to_mul(ex)
	quote 
		$(ex.args[2]) * $(ex.args[3])
	end
end

# ╔═╡ 309bee08-7f31-4185-bb89-3f6a1715157a
@change_op_to_mul 5 + 5

# ╔═╡ 5024e1ab-1b03-4145-bca8-48a2ab8a0fe1
@change_op_to_mul 5 / 5

# ╔═╡ 4b1ea454-ff92-4b26-a9ab-dbd6c20599bf
md"""
!!! note
	R's "Non-standard evaluation" makes every function macro-ish.
"""

# ╔═╡ 5d99e59e-11d1-4ab0-884d-dfcefbde165c
md"""
# Learnings from R

!!! note
	In many cases

	> "lessons learned from R"

	is really

	> "lessons learned from Doug"

	or 

	> "code contributions from Doug"
"""

# ╔═╡ a0d6bcd3-eff8-492c-8983-00974ec5eea4
begin
	screenshots = joinpath.(Ref("github_screenshots"), readdir("github_screenshots"));
	md"""
	$(@bind timer Clock(1))

	#### A sample of comments in GitHub issues:
	"""
end

# ╔═╡ 678a6bfc-6758-4ab3-8bc4-c3eb8fecee3b
begin
	i = (timer % length(screenshots)) + 1
	LocalResource(screenshots[i], :height => "40px")
end

# ╔═╡ 0f6adb16-e9d5-47cf-9457-6dda141ec51a
md"""
!!! note "The Influence of Dr. Doug Bates"
	Doug provided the [JuliaStats](https://github.com/JuliaStats) community with a plethora of knowledge about the inner workings of R (as well as why certain decisions were made).
"""

# ╔═╡ 67d27cda-4799-4762-b470-19de5708538b
md"""
## What Julia has borrowed from R
"""

# ╔═╡ 75bba6bd-2060-4fbe-9b62-d6df3e4c24ad
md"""
!!! highlight "1) Formula syntax"
	R's formula syntax is great.

	- Julia doesn't use R's "non-standard evaluation".
	- In order to access an expression, we need macros:

	```julia
	using StatsModels 

	@formula y ~ 1 + x
	```
"""

# ╔═╡ e69b0fe5-ab03-466d-8afa-74d35d081358
md"""
!!! warn "2) The core of fitting Generalized Linear Models"
	- Many of the comments above come from **GLM.jl**.
	- If you squint, the Julia code looks like R.

	```julia
	url = "https://cdn.jsdelivr.net/gh/allisonhorst/palmerpenguins@433439c8b013eff3d36c847bb7a27fa0d7e353d8/inst/extdata/penguins.csv"
	
	penguins = CSV.read(read(download(url)), DataFrame, missingstring=["NA"])
	
	lm(@formula(bill_length_mm ~ 1 + island), penguins)
	```
"""

# ╔═╡ a75ece9b-d89b-43ae-af82-24c0d79135d9
let
	url = "https://cdn.jsdelivr.net/gh/allisonhorst/palmerpenguins@433439c8b013eff3d36c847bb7a27fa0d7e353d8/inst/extdata/penguins.csv";
	penguins = CSV.read(read(download(url)), DataFrame, missingstring=["NA"]);
	lm(@formula(bill_length_mm ~ 1 + island), penguins)
end

# ╔═╡ de234030-70c0-408b-9646-ec9c3d237994
md"""
!!! highlight "3) The rest of the language"
	- **RCall.jl** provides fantastic calling-R-from-Julia interop.
	- The time you've spent learning `lattice`/`ggplot2`/etc. doesn't go to waste when you switch to Julia.
	  - If I recall correctly, Doug wrote **RCall** for this very reason.
"""

# ╔═╡ 38634e92-b813-4823-bbe0-6aedbffbedb2
md"""
# Using R from Julia
"""

# ╔═╡ 6a62a82c-320c-4786-b846-b7056be8b9be
md"""
!!! note
	- Plots from R don't automatically diplay in Pluto.
	- Good opportunity to write a macro:
"""

# ╔═╡ 3c3d69d0-3874-453c-9de1-ce3a2a93f663
macro ggplot2(ex)
	nm = tempname() * ".png"
	s = string(ex)
	s2 = "ggsave(\"$nm\", height=4)"
	esc(quote
		let 
			@R_str $s
			@R_str $s2
			LocalResource($nm) 
		end
	end)
end

# ╔═╡ ed3adc2e-28ca-489c-a5a3-ca425f92e28f
begin
	R"library(ggplot2)"
	@ggplot2 ggplot(mpg, aes(displ, hwy, colour = class)) + geom_point()
end

# ╔═╡ 0ad9751a-d0fd-4ec1-8e8e-08d16868990a
md"""
!!! note "Passing variables from Julia to R"
	You can pass Julia variables to R using:
	  1. `$` interpolation syntax inside `R"..."`.
	  2. The `@rput` macro.
"""

# ╔═╡ 4f2929bb-8a82-4fe5-8a09-70e47bdc408a
y = randn(1000)

# ╔═╡ 3fe50422-12ed-44d8-a068-7eb60b846eda
@ggplot2 ggplot(mapping=aes($y)) + geom_histogram()

# ╔═╡ 38b373ca-b5c4-407a-961a-a38c0824423e
md"""
!!! note "Retrieve values from R"
	- Similar to `@rput`, we have `@rget`.
	- Type conversions are automatic for many things, but you can write your own custom conversions as well.
"""

# ╔═╡ 2bedfb05-b4f9-419e-b07e-33bda10f0855
md"""
# Should you try Julia?
"""

# ╔═╡ 3bd96954-b28b-42f9-9678-b1cb93bea0b5
md"""
!!! yes "Yes if:"
	- You develop novel algorithms.
	- You care about performance.
	- You don't have a large stack of dependencies.
	- You occasionally prefer to write your own implementation.
"""

# ╔═╡ 6e6c9ee4-4ba9-410a-af8b-341303356d1d
md"""
!!! warning "Maybe if:"
	- You're trying to speed up your code with RCpp.
"""

# ╔═╡ da6fed74-081e-488a-822c-5fe53a299f30
md"""
!!! danger "No if:"
	- You heavily depend on packages that only exist in your language of choice (*and you don't want to implement it yourself*).
	- Your language of choice is already good (enough).
"""

# ╔═╡ 82e6f29a-fa7d-4250-9793-b99d4712bac9
md"""
---

!!! note
	One thing I want to emphasize is **don't be scared of the perceived additional complexity** over R.

	- It's very easy to write high-level code.
	- Low-level idiosyncratic things are available, but not necessary.
"""

# ╔═╡ c2f2b913-bc2b-465c-8af2-b659ff3b64de
md"""
# Thank You!

- Find me on GitHub: [`@joshday`](https://github.com/joshday)

#### Julia Resources

- Discourse
- Slack
- Official Julia Documentation
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AbstractTrees = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
Cobweb = "ec354790-cf28-43e8-bb59-b484409b7bad"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
EasyConfig = "acab07b0-f158-46d4-8913-50acef6d41fe"
GLM = "38e38edf-8417-5370-95a0-9cbb8c7f171a"
PlotlyLight = "ca7969ec-10b3-423e-8d99-40f33abb42bf"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
RCall = "6f49c342-dc21-5d91-9882-a32aef131414"
StatsModels = "3eaba693-59b7-5ba5-a881-562e759f1c8d"

[compat]
AbstractTrees = "~0.4.4"
CSV = "~0.10.11"
Cobweb = "~0.5.2"
DataFrames = "~1.6.1"
Distributions = "~0.25.98"
EasyConfig = "~0.1.15"
GLM = "~1.8.3"
PlotlyLight = "~0.7.3"
PlutoUI = "~0.7.52"
RCall = "~0.13.15"
StatsModels = "~0.7.2"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.2"
manifest_format = "2.0"
project_hash = "4fd9ab6315b846e72d3aef91055566381a2aba76"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "91bd53c39b9cbfb5ef4b015e8b582d344532bd0a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.0"

[[deps.AbstractTrees]]
git-tree-sha1 = "faa260e4cb5aba097a73fab382dd4b5819d8ec8c"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "PrecompileTools", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "44dbf560808d49041989b8a96cae4cffbeb7966a"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.11"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.CategoricalArrays]]
deps = ["DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "1568b28f91293458345dabba6a5ea3f183250a61"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.8"

    [deps.CategoricalArrays.extensions]
    CategoricalArraysJSONExt = "JSON"
    CategoricalArraysRecipesBaseExt = "RecipesBase"
    CategoricalArraysSentinelArraysExt = "SentinelArrays"
    CategoricalArraysStructTypesExt = "StructTypes"

    [deps.CategoricalArrays.weakdeps]
    JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    SentinelArrays = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
    StructTypes = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"

[[deps.Cobweb]]
deps = ["DefaultApplication", "Markdown", "OrderedCollections", "Random", "Scratch"]
git-tree-sha1 = "49e3de5be079f856697995001c587db8605506a9"
uuid = "ec354790-cf28-43e8-bb59-b484409b7bad"
version = "0.5.2"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "02aa26a4cf76381be7f66e020a3eddeb27b0a092"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.2"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "e460f044ca8b99be31d35fe54fc33a5c33dd8ed7"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.9.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.Conda]]
deps = ["Downloads", "JSON", "VersionParsing"]
git-tree-sha1 = "8c86e48c0db1564a1d49548d3515ced5d604c408"
uuid = "8f4d0f93-b110-5947-807f-2305c1781a2d"
version = "1.9.1"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "04c738083f29f86e62c8afc341f0967d8717bdb8"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.6.1"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "cf25ccb972fec4e4817764d01c82386ae94f77b4"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.14"

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

[[deps.Distributions]]
deps = ["FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "e76a3281de2719d7c81ed62c6ea7057380c87b1d"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.98"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.EasyConfig]]
deps = ["JSON3", "OrderedCollections", "StructTypes"]
git-tree-sha1 = "d22224e636afcb14de0cb5a0a7039095e2238aee"
uuid = "acab07b0-f158-46d4-8913-50acef6d41fe"
version = "0.1.15"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "e27c4ebe80e8699540f2d6c805cc12203b614f12"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.20"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "f372472e8672b1d993e93dada09e23139b509f9e"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.5.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLM]]
deps = ["Distributions", "LinearAlgebra", "Printf", "Reexport", "SparseArrays", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns", "StatsModels"]
git-tree-sha1 = "97829cfda0df99ddaeaafb5b370d6cab87b7013e"
uuid = "38e38edf-8417-5370-95a0-9cbb8c7f171a"
version = "1.8.3"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "f218fe3736ddf977e0e772bc9a586b2383da2685"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.23"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "d75853a0bdbfb1ac815478bacd89cd27b550ace6"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.3"

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

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "PrecompileTools", "StructTypes", "UUIDs"]
git-tree-sha1 = "95220473901735a0f4df9d1ca5b171b568b2daa3"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.13.2"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "c3ce8e7420b3a6e071e0fe4745f5d4300e37b13f"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.24"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

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
version = "2.28.2+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "2e73fe17cac3c62ad1aebe70d44c963c3cfdc3e3"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.2"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "67eae2738d63117a196f497d7db789821bce61d1"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.17"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "716e24b21538abc91f6205fd1d8363f39b442851"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.2"

[[deps.PlotlyLight]]
deps = ["Artifacts", "Cobweb", "DefaultApplication", "Downloads", "EasyConfig", "JSON3", "Random", "Scratch", "StructTypes"]
git-tree-sha1 = "dc3346512c0cb475b578825e66bffe53b77d6fec"
uuid = "ca7969ec-10b3-423e-8d99-40f33abb42bf"
version = "0.7.3"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "e47cd150dbe0443c3a3651bc5b9cbd5576ab75b7"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.52"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "9673d39decc5feece56ef3940e5dafba15ba0f81"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.1.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "7eb1686b4f04b82f96ed7a4ea5890a4f0c7a09f1"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.0"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "ee094908d720185ddbdc58dbe0c1cbe35453ec7a"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.7"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "6ec7ac8412e83d57e313393220879ede1740f9ee"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.8.2"

[[deps.RCall]]
deps = ["CategoricalArrays", "Conda", "DataFrames", "DataStructures", "Dates", "Libdl", "Missings", "REPL", "Random", "Requires", "StatsModels", "WinReg"]
git-tree-sha1 = "d441bdeea943f8e8f293e0e3a78fe2d7c3aa24e6"
uuid = "6f49c342-dc21-5d91-9882-a32aef131414"
version = "0.13.15"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "f65dcb5fa46aee0cf9ed6274ccbd597adc49aa7b"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.1"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6ed52fdd3382cf21947b15e8870ac0ddbff736da"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.4.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "30449ee12237627992a99d5e30ae63e4d78cd24a"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "04bdff0b09c65ff3e06a05e3eb7b120223da3d39"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.ShiftedArrays]]
git-tree-sha1 = "503688b59397b3307443af35cd953a13e8005c16"
uuid = "1277b4bf-5013-50f5-be3d-901d8477a67a"
version = "2.0.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "c60ec5c62180f27efea3ba2908480f8055e17cee"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "7beb031cf8145577fbccacd94b8a8f4ce78428d3"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.3.0"

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

    [deps.SpecialFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "45a7769a04a3cf80da1c1c7c60caf932e6f4c9f7"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.6.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "75ebe04c5bed70b91614d684259b661c9e6274a4"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.0"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "f625d686d5a88bcd2b15cd81f18f98186fdc0c9a"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.3.0"

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

    [deps.StatsFuns.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.StatsModels]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Printf", "REPL", "ShiftedArrays", "SparseArrays", "StatsBase", "StatsFuns", "Tables"]
git-tree-sha1 = "8cc7a5385ecaa420f0b3426f9b0135d0df0638ed"
uuid = "3eaba693-59b7-5ba5-a881-562e759f1c8d"
version = "0.7.2"

[[deps.StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "ca4bccb03acf9faaf4137a9abc1881ed1841aa70"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.10.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

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
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "1544b926975372da01227b382066ab70e574a3ec"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "9a6ae7ed916312b41236fcef7e0af564ef934769"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.13"

[[deps.Tricks]]
git-tree-sha1 = "aadb748be58b492045b4f56166b5188aa63ce549"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.7"

[[deps.URIs]]
git-tree-sha1 = "074f993b0ca030848b897beff716d93aca60f06a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.VersionParsing]]
git-tree-sha1 = "58d6e80b4ee071f5efd07fda82cb9fbe17200868"
uuid = "81def892-9a0e-5fdd-b105-ffc91e053289"
version = "1.3.0"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.WinReg]]
git-tree-sha1 = "cd910906b099402bcc50b3eafa9634244e5ec83b"
uuid = "1b915085-20d7-51cf-bf83-8f477d6f5128"
version = "1.0.0"

[[deps.WorkerUtilities]]
git-tree-sha1 = "cd1659ba0d57b71a464a29e64dbc67cfe83d54e7"
uuid = "76eceee3-57b5-4d4a-8e66-0e911cebbf60"
version = "1.6.1"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─28c981d6-30ab-45fd-bc5f-7649eb371894
# ╟─4c4b2682-d008-416e-8898-85fd2250d877
# ╟─1da9ab32-7f8e-4ffb-82c9-b584e33e522c
# ╟─ec35cc71-9656-4a4f-b854-d69b3abc3851
# ╟─8fcfaeca-eab8-4e30-ac80-5bf77e4d8f97
# ╟─4f56158c-5e53-4dcb-a62b-6a0fb7bc6d1b
# ╟─be5c6bcd-fcd0-4637-ba74-3db56aa70458
# ╠═6db786aa-7e5f-4911-99f9-1cd5ff567698
# ╠═f2a88086-dcc1-449e-8ee2-23bb14fac992
# ╠═3eaafd87-508f-484c-9816-9a90518b3cb0
# ╟─3754ba52-4617-4313-bcc4-d86bd2dc10a8
# ╟─de051b5d-adaa-4d6e-a2a7-498fee248201
# ╟─4284c6e9-2801-4e63-870f-4ebf6b9ab3d8
# ╟─f809185e-c624-42bd-9b91-68b2dd854672
# ╠═7f1be803-c01c-4223-bf63-19c5b5a4d781
# ╠═4318a3e9-b33c-47aa-8a5b-10cf33a84f96
# ╟─e43a9b9f-369f-44a4-804f-f50b64fb49fe
# ╟─77230db4-dfaa-4559-a054-328931a0bb56
# ╟─44d794c1-fa56-4d71-950d-da8c77f926ea
# ╠═daebeaf7-b7a5-4a29-afd5-19b57a0f37f7
# ╟─a724cfe9-9b7c-43c8-80a0-ce87325cf327
# ╟─24a31b5d-7309-4774-8adb-acb6d462525c
# ╟─9f45fc0d-33ee-4e43-813c-ddc25ac755f7
# ╠═27f7a89f-de60-4753-8fd6-73964ae3c600
# ╟─4a9081f9-df1c-4ed1-a38f-64af8b1c527f
# ╠═7df066ec-2d70-44b9-809c-3d90bc765890
# ╠═c50b6262-77ab-486b-8b86-b61ed07e6f50
# ╠═e7d3f396-a446-485e-9022-77f7ddc73472
# ╠═62c23af8-c3b6-4226-a665-17d40d126c01
# ╠═309bee08-7f31-4185-bb89-3f6a1715157a
# ╠═5024e1ab-1b03-4145-bca8-48a2ab8a0fe1
# ╟─4b1ea454-ff92-4b26-a9ab-dbd6c20599bf
# ╟─5d99e59e-11d1-4ab0-884d-dfcefbde165c
# ╟─a0d6bcd3-eff8-492c-8983-00974ec5eea4
# ╟─678a6bfc-6758-4ab3-8bc4-c3eb8fecee3b
# ╟─0f6adb16-e9d5-47cf-9457-6dda141ec51a
# ╟─67d27cda-4799-4762-b470-19de5708538b
# ╟─75bba6bd-2060-4fbe-9b62-d6df3e4c24ad
# ╟─e69b0fe5-ab03-466d-8afa-74d35d081358
# ╟─a75ece9b-d89b-43ae-af82-24c0d79135d9
# ╟─de234030-70c0-408b-9646-ec9c3d237994
# ╟─38634e92-b813-4823-bbe0-6aedbffbedb2
# ╟─6a62a82c-320c-4786-b846-b7056be8b9be
# ╟─3c3d69d0-3874-453c-9de1-ce3a2a93f663
# ╠═ed3adc2e-28ca-489c-a5a3-ca425f92e28f
# ╟─0ad9751a-d0fd-4ec1-8e8e-08d16868990a
# ╠═4f2929bb-8a82-4fe5-8a09-70e47bdc408a
# ╠═3fe50422-12ed-44d8-a068-7eb60b846eda
# ╟─38b373ca-b5c4-407a-961a-a38c0824423e
# ╟─2bedfb05-b4f9-419e-b07e-33bda10f0855
# ╟─3bd96954-b28b-42f9-9678-b1cb93bea0b5
# ╟─6e6c9ee4-4ba9-410a-af8b-341303356d1d
# ╟─da6fed74-081e-488a-822c-5fe53a299f30
# ╟─82e6f29a-fa7d-4250-9793-b99d4712bac9
# ╟─c2f2b913-bc2b-465c-8af2-b659ff3b64de
# ╟─f611d61e-30a1-11ee-3119-99255be33a07
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
