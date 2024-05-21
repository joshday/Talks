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

# ╔═╡ b3f73ba6-07ca-11ef-15eb-895008db2a32
begin
	using Distributions
	using PlotlyLight
	using PlutoUI
	md"""
	(notebook setup)
	$(PlutoUI.TableOfContents())
	$(HTML("<style>h1 { padding-top: 200px; }</style>"))
	$(HTML("<style>h2 { padding-top: 100px; }</style>"))
	$(HTML("<style>h3 { padding-top: 50px; }</style>"))
	"""
end

# ╔═╡ c049e7b0-f3c4-4ee9-a699-f941e5970405
let
	using AbstractTrees
	
	# In general, don't do this!
	# Piracy is defining a method on a type when you "own" neither.
	AbstractTrees.children(T::DataType) = subtypes(T)
	print_tree(Real)
end

# ╔═╡ fbba6ab9-3339-4d3f-964b-81e4f625f7e9
using LinearAlgebra

# ╔═╡ fa88b54f-2e74-474d-a772-e252ac29794d
using RCall

# ╔═╡ de3078e6-7102-4e73-aff2-93a2835967d6
using DataFrames

# ╔═╡ 613d1b35-d482-47ad-bb52-b20af0a6408d
md"""
# Useful Link: [Julia Cheatsheet](https://cheatsheet.juliadocs.org)
"""

# ╔═╡ eb817e23-6149-470e-ba99-e07ddfaf74e1
md"""
# Why Julia?

##### Why would we want/need another language?

!!! info "Julia Really is Nice"
	- Frankly I'm surprised that Julia has had little traction among (computational) statisticians.
	- I feel like learning Julia gave me super powers for my computationally-heavy research.
"""

# ╔═╡ b84af093-7737-4250-9777-c6d37a7a6bc1
md"# Three Claims About Julia"

# ╔═╡ a7b9de96-b0ef-432d-8e8c-410916f900b1
md"""
## Claim 1

!!! highlight "Julia Solves the \"Two-Language Problem\""

	### The Two-Language Problem:
	#### 1. You write **prototype** code in an *easy* language.
	#### 2. You write **production** code in a *fast* language.

	!!! note "Example"
		##### 1. You write a script to verify your new algorithm works.
		##### 2. You now want to release your algorithm in a software package.

	!!! note "Evidence that Julia Solves The Two-Language Problem"
		##### Most Julia packages are 100% Julia!
		##### User-defined functions are **no different** than built-in functions.
		##### Much of Julia is written...in Julia.
"""

# ╔═╡ 2614ee96-20c6-459c-b599-1891bbb644b5
md"""
## Claim 2

!!! highlight "Julia Solves the \"Two-Culture Problem\""

	![](https://user-images.githubusercontent.com/8075494/240981379-459fe8b7-7bc7-4652-ab79-889c32221225.png)
	
	![](https://user-images.githubusercontent.com/8075494/240981352-5824c33a-1a87-4213-8585-d53df2bfbb25.png)

	- Images borrowed from [https://scientificcoder.com/my-target-audience](https://scientificcoder.com/my-target-audience)

	> If you work with just one other person, you've probably experienced some level of this.

"""

# ╔═╡ 1814c337-2379-466c-97df-dbee6362ce5c
md"""
!!! info
	In Academia, "bring ideas to production" could simply mean "I want my simulations to run in an hour, not over the weekend"
"""

# ╔═╡ 630a7f0f-b5df-496e-a4c7-4c7d3debf8bd
md"""
## Claim 3

!!! highlight "Learning Julia Changes how You Solve Problems with Code"

	#### The Sapir-Whorf Hypothesis
	> The particular language one speaks influences the way one thinks about reality.
	> - [https://www.sciencedirect.com/topics/psychology/sapir-whorf-hypothesis](https://www.sciencedirect.com/topics/psychology/sapir-whorf-hypothesis)
	
	###### The Programming Language version:
	> Your language influences how you solve problems.


	###### Combining ideas from claims 2 and 3:

	> I'm going to use a hypothetical language called Blub...
	> 
	> As long as our hypothetical Blub programmer is looking down the power continuum, they know they're looking down. Languages less powerful than Blub are obviously less powerful, because they're missing features our programmer is used to. But **when our programmer looks up the power continuum, they don't realize they're looking up. What they see are merely weird languages.** They probably consider them about equivalent in power to Blub, but with all this other hairy stuff thrown in as well. Blub is good enough for them, because they think in Blub.
	> - Paraphrased from Paul Graham's ["Beating the Averages" Essay](http://www.paulgraham.com/avg.html) (emphasis added)
"""

# ╔═╡ 65bb64e2-194b-41b5-8228-afc90c165497
md"""
# Julia Highlights
"""

# ╔═╡ 47fead9c-9bca-49db-984c-20988edd562c
md"""
## Performance

$(html"<img style='background:white; border-radius:4px;' src='https://julialang.org/assets/images/benchmarks.svg'>")
"""

# ╔═╡ 32661546-6615-4782-93dd-94cc18554e37
md"""
!!! success "Quick Story"
	- At my first JuliaCon (2016), I saw Doug Bates (of `lme4` fame) give a 10 minute lightning talk about `MixedModels.jl`.
	- He'd translated a model from R to Julia that took "most of the day" to fit  in his "best-written R code".
	- He coded live and fit the model within his 10 minute talk.
"""

# ╔═╡ b9589e8f-71c5-4d52-805d-d745d778bcc7
md"""
## Automatic Specialization

!!! note "Julia uses a Just-in-time (JIT) compiler (LLVM)"
	

	- Start with a simple function:
	```julia
	f(x, y) = x + y
	```

	- `f(1, 2)` will compile a *method* for `f(::Int,::Int)`
	- `f(1.0, 2.0)` will compile a *method* for `f(::Float64, ::Float64)`
	- The next time you call a compiled method you don't need to recompile it, e.g. `f(4,5)`.
"""

# ╔═╡ e1e100c6-5f85-4c73-bd93-f8d5fca6d0ff
md"""
!!! info "Specialized code \"for free\""
	You get *specialized* code without telling Julia about the types of inputs.
"""

# ╔═╡ 33092efb-687e-4601-8a5b-92ce52a85ea1
md"""
!!! note "A more complicated example (think about Sapir-Worf)"

	Finding quantiles with Newton's Method for finding roots:
	
	$$\text{Solve for } x \text{:}\quad F_X(x) - q= 0$$
	
	- where $F_X$ is CDF of random variable $X$.
	
	$$x_{n+1} = x_n - \frac{F_X(x_n) - q}{F_X'(x_n)}$$

"""

# ╔═╡ 891ce1f8-efd7-4fcb-ac98-516c2fb01398
function myquantile(dist, q)
    x = mean(dist)
    for i in 1:20
        x -= (cdf(dist, x) - q) / pdf(dist, x)
    end
    x
end

# ╔═╡ 51a426b8-5ab7-4887-8ae5-f9f153324efe
md"""
#### Does it Work?

$(@bind dist Select([nothing, Normal(), Gamma(5,1), Uniform(0,1), Beta(7,2)]))
"""

# ╔═╡ 6ebb149b-9f16-4615-ba23-7e01d8d9e46b
let
	rng = .01:.01:.99
	if isnothing(dist) 
		nothing 
	else
		p = Plot()(
			y=rng, x=quantile.(dist, rng), name="quantile"
		)(
			y=rng, x=myquantile.(dist, .01:.01:.99), line=(;dash="dot"),
			name="myquantile"
		)
		p.layout.title=string(dist)
		p.layout.xaxis.title = "x"
		p.layout.yaxis.title = "P(X) < x"
		p
	end
end

# ╔═╡ 9eee6aa0-4710-444e-b320-953c3b4277cf
md"""
## Type System/Multiple Dispatch

- Abstract types don't "exist", but define a set.
- Concrete types "exist".

!!! note "Types: Think Sets"
	Using an abstract type in a type annotation (e.g. `f(::Real)`) says:

	> this function works with any type from this set.

	- Subtypes of `Real`:
"""

# ╔═╡ 324a0b89-f160-42b3-88b4-ce7e27298236
md"""
!!! info "Type Annotations"
	*Type Annotations* do not affect performance. e.g.

	```julia
	f(x::Real) = x + x
	```

	They are used for two things:
	
	1. **Validating user inputs.** E.g. You never need to do this:
	```julia
		function f(x)
			x isa Real || error("x should be a real number")
		end
	```
	2. **(Multiple) Dispatch**.  E.g.

	- Function has a different meaning (or optimization) depending on the type:

	```julia
	half(x::Number) = x / 2 

    half(x) = x[1:floor(Int, length(x) / 2)]
	```
"""

# ╔═╡ efd5cdf5-7961-4747-8a2e-307f6aba60f3
begin 
	half(x::Number) = x / 2 

    half(x) = x[1:floor(Int, length(x) / 2)]
end

# ╔═╡ 8c68f965-493b-4465-941c-9cd10629de2d
half(1)

# ╔═╡ cafbc4ef-a007-4588-ba30-ff0fceae19ae
half(1 + 2im)

# ╔═╡ e410a3d8-7f8b-46ab-988b-06432bf9c5bd
half("ABCDEFG")

# ╔═╡ 9c093d57-dffc-45ef-a3bc-68b69ab17e80
half(1:10)

# ╔═╡ 02d38202-ef44-44d3-8780-edd3217c3133
md"""
### Multiple Dispatch Example: `Matrix` vs. `Diagonal`
"""

# ╔═╡ 8a2f5a79-3229-4a73-afa3-70cfe0666e65
md"""
!!! note "Note: Dispatch and Multiple Dispatch"
    - **Dispatch** is the choice of which method to execute when a function is applied. 
	- **Multiple Dispatch** is dispatch based on the types of *all* arguments to a function.
"""

# ╔═╡ a6d3bd52-5228-42eb-9a1c-f99bccd4951e
let 
	# `Diagonal` doesn't store the off-diagonal elements
	x = Diagonal(randn(1000))

	# `Matrix` stores the off-diagonals (all are 0.0)
	x2 = Matrix(x)
	
	y = randn(1000)

	
	t1 = @elapsed x * y
	t2 = @elapsed x2 * y
	@info "Dense matrix multiply is $(t2/ t1) times slower than Diagonal."
end

# ╔═╡ 2a960f22-0d11-49fe-9f4b-db5a21afcdec
md"""
!!! note "How does this work?"
	- The `*(::Diagonal, ::Vector)` method is faster than the `*(::Matrix, ::Vector)` method.
"""

# ╔═╡ 3f2521e9-81ac-4bb9-8c74-e1961c090e50
md"""
!!! note "How MixedModels.jl uses Multiple Dispatch"
	#### MixedModels.jl takes great advantage of this!

	###### Design matrices in mixed effect models have lot of structure:
	- Block diagonal
	- Block sparse 

	###### MixedModels.jl doesn't need separate implementations for different structures in a design matrix.
	- It just needs to rely on the methods (e.g. `*`, `+`) that are optimized for its `AbstractMatrix` types.
"""

# ╔═╡ 6f0d1339-d1f2-4344-bb5a-465ab2a49300
md"""
!!! note "Related: Julia Packages are Often "Composable\""
	- I.e. they work together without an explicit dependency.

	##### Example
	- You write a function `f(::AbstractMatrix)`.
	- Now you realize your input is a block matrix, so you use **BlockArrays.jl** for a free speedup.
"""

# ╔═╡ b59871d8-0ce1-4bbd-b698-b461ffef5561
md"""
## Broadcasting

- Make operations more explicit at the cost of one character.

```julia
x = randn(100)

# There's no mathematical definition of the absolute value of a vector.
abs(x)  # Error

# "broadcast" `abs` to each element of `x`
abs.(x)  
```
!!! info "Chaining Broadcasts"
	You can "chain" broadcasts to avoid temporary copies -> Big performance gains!

	##### Example

	- In Julia: no temporary vectors → less **garbage collection**
	```julia
	abs.(sin.(sqrt.(1:100 .+ 10)))
	```

	- In R:
	```R
	y = abs(sin(sqrt(1:100 + 10)))

	# is essentially:
	temp1 = 1:100 + 10
	temp2 = sqrt(temp1)
	temp3 = sin(temp2)
	abs(temp3)

	# You can avoid temporary vectors:
	sapply(1:100, function(x) abs(sin(sqrt(x + 10))))

	# But...the path of least resistance is what's above 
	```
"""

# ╔═╡ 7a8a9af0-2f7a-4282-b1df-ef5aea865a41
md"""
## Metaprogramming/Macros

!!! note "What is a Macro?"
	A function of an *expression*.  Macros can change an expression before it gets evaluated.

	- Julia expressions are **represented in Julia (`Expr`)**.

	```julia
	@mymacro 1 + 2
	```

	- `@mymacro`'s input here is `Expr(:call, :+, 1, 2)`
"""

# ╔═╡ f747b27a-658a-4692-9e8b-ec4bdf40f1aa
dump(Meta.parse("1 + 1"))

# ╔═╡ fcd90d06-bce5-442f-89a4-d049a1b3c826
# Change second argument of infix operator to `100`
macro mymacro(ex)
	ex.args[end] = 100
	return ex
end

# ╔═╡ 22ec7170-ed1c-4d92-9a30-c6b9cab84bca
@mymacro 1 + 2

# ╔═╡ a046bd56-40a7-4130-bbb4-2ed28ee9d103
@mymacro 2 * "This will get replaced"

# ╔═╡ 55e31504-27ae-427d-92d5-0e942c9bb8e5
md"""
!!! note
	R's "Non-standard evaluation" makes every function macro-like.
"""

# ╔═╡ 97c70ec5-93b7-4503-9de9-67db304d3eb7
md"""
# Mutation

!!! note "\"Pass by Sharing\""
	In Julia, function arguments are passed "by sharing" (AKA "by reference") and a function can change the value of an argument.  By convention, mutating functions end with `!`. 

	Note that in R, arguments are passed "by copy", with the exception of a few special data types.
"""

# ╔═╡ e4498937-6b26-4e74-a66c-94f74694f5b7
let 
	x = [1, 2]
	push!(x, 3)  # Add `3` to the end
	popfirst!(x)  # Remove `1` from the start
	x
end

# ╔═╡ cd4e9a48-eee4-4d0d-b0f9-5359bf92041f
md"""
## Reproducibility

!!! note "Pkg"
	- Julia's package manager (Pkg) works **really, really well**.
	- Great system for "artifacts" (any data that isn't Julia code).
	- Package registry has a lot of "JLL" packages (platform-specific binary dependencies), e.g. `SQLite_jll.jl` is used by the `SQLite.jl` package.

!!! note "Reproducibility is a Community Effort"
	- Reproducibility is important to the community as a whole.
	- **Pluto** notebooks are a self-contained text (`.jl`) file.
	  - When sharing, the recipient will get the **identical environment** as the sender.

"""

# ╔═╡ 19b06d54-72c1-423c-9039-446fee67aed5
md"""
# Using R from Julia
"""

# ╔═╡ fd5f7245-e21e-4cbd-a15e-41609de683e1
md"""
!!! note
	- Plots from R don't automatically diplay in Pluto.
	- Good opportunity to write a macro:
"""

# ╔═╡ ea4939cc-cdac-4c36-9b57-7c3100fc1e2e
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

# ╔═╡ edc198d0-95ff-4eea-a0d4-57336092bfaf
begin
	R"library(ggplot2)"  # Use the `R` string macro to load ggplot2
	
	@ggplot2 ggplot(mpg, aes(displ, hwy, colour = class)) + geom_point()
end

# ╔═╡ 03aed7c0-dc38-45dd-b965-01316bfdf947
md"""
!!! note "Passing variables from Julia to R"
	You can pass Julia variables to R using:
	  1. `$` interpolation syntax inside `R"..."`.
	  2. The `@rput` macro.
"""

# ╔═╡ d181b7c8-9f69-4786-b643-4a2d0aa14f3e
julia_data = randn(1000)

# ╔═╡ 19b8232d-16e1-4b22-805e-16ffc17c9ae0
@ggplot2 ggplot(mapping=aes($julia_data)) + geom_histogram()

# ╔═╡ 6a4fbd54-d5f2-4cc1-a58a-6d28a535de1a
md"""
!!! note "Retrieve values from R"
	- Similar to `@rput`, we have `@rget`.
	- Type conversions are automatic for many things, but you can write your own custom conversions as well.
"""

# ╔═╡ f15bf377-6b8c-4b53-8b9f-ec438144ff9b
let 
	R"data <- mpg"
	
	@rget data
	
	describe(data)
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AbstractTrees = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
PlotlyLight = "ca7969ec-10b3-423e-8d99-40f33abb42bf"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
RCall = "6f49c342-dc21-5d91-9882-a32aef131414"

[compat]
AbstractTrees = "~0.4.5"
DataFrames = "~1.6.1"
Distributions = "~0.25.108"
PlotlyLight = "~0.9.1"
PlutoUI = "~0.7.59"
RCall = "~0.14.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.3"
manifest_format = "2.0"
project_hash = "842214971ee1312ba3561e26ba0a3a0e984332a3"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.AbstractTrees]]
git-tree-sha1 = "2d9c9a55f9c93e8887ad391fbae72f8ef55e1177"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.5"

[[deps.AliasTables]]
deps = ["Random"]
git-tree-sha1 = "07591db28451b3e45f4c0088a2d5e986ae5aa92d"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

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
deps = ["DefaultApplication", "OrderedCollections", "Scratch"]
git-tree-sha1 = "1d38f9c609b1d8b33319911b4f016da29e33a776"
uuid = "ec354790-cf28-43e8-bb59-b484409b7bad"
version = "0.6.1"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "c955881e3c981181362ae4088b35995446298b80"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.14.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.Conda]]
deps = ["Downloads", "JSON", "VersionParsing"]
git-tree-sha1 = "51cab8e982c5b598eea9c8ceaced4b58d9dd37c9"
uuid = "8f4d0f93-b110-5947-807f-2305c1781a2d"
version = "1.10.0"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

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

[[deps.Distributions]]
deps = ["AliasTables", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns"]
git-tree-sha1 = "22c595ca4146c07b16bcf9c8bea86f731f7109d2"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.108"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"
    DistributionsTestExt = "Test"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

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
git-tree-sha1 = "11fa8ecd53631b01a2af60e16795f8b4731eb391"
uuid = "acab07b0-f158-46d4-8913-50acef6d41fe"
version = "0.1.16"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "57f08d5665e76397e96b168f9acc12ab17c84a68"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.10.2"
weakdeps = ["PDMats", "SparseArrays", "Statistics"]

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "f218fe3736ddf977e0e772bc9a586b2383da2685"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.23"

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

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

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

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "18144f3e9cbe9b15b070288eef858f71b291ce37"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.27"

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
version = "0.3.23+4"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+2"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "949347156c25054de2db3b166c52ac4728cbad65"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.31"

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
git-tree-sha1 = "88b895d13d53b5577fd53379d913b9ab9ac82660"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.3.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "9b23c31e76e333e6fb4c1595ae6afa74966a729e"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.9.4"

[[deps.RCall]]
deps = ["CategoricalArrays", "Conda", "DataFrames", "DataStructures", "Dates", "Libdl", "Missings", "Preferences", "REPL", "Random", "Requires", "StatsModels", "WinReg"]
git-tree-sha1 = "846b2aab2d312fda5e7b099fc217c661e8fae27e"
uuid = "6f49c342-dc21-5d91-9882-a32aef131414"
version = "0.14.1"

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
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "0e7508ff27ba32f26cd459474ca2ede1bc10991f"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.1"

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
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "e2cfc4012a19088254b3950b85c3c1d8882d864d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.3.1"

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

    [deps.SpecialFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "5cf7606d6cef84b543b483848d4ae08ad9832b21"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.3"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "cef0472124fab0695b58ca35a77c6fb942fdab8a"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.3.1"

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

    [deps.StatsFuns.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.StatsModels]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Printf", "REPL", "ShiftedArrays", "SparseArrays", "StatsAPI", "StatsBase", "StatsFuns", "Tables"]
git-tree-sha1 = "5cf6c4583533ee38639f73b880f35fc85f2941e0"
uuid = "3eaba693-59b7-5ba5-a881-562e759f1c8d"
version = "0.7.3"

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

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

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

[[deps.VersionParsing]]
git-tree-sha1 = "58d6e80b4ee071f5efd07fda82cb9fbe17200868"
uuid = "81def892-9a0e-5fdd-b105-ffc91e053289"
version = "1.3.0"

[[deps.WinReg]]
git-tree-sha1 = "cd910906b099402bcc50b3eafa9634244e5ec83b"
uuid = "1b915085-20d7-51cf-bf83-8f477d6f5128"
version = "1.0.0"

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
# ╟─b3f73ba6-07ca-11ef-15eb-895008db2a32
# ╟─613d1b35-d482-47ad-bb52-b20af0a6408d
# ╟─eb817e23-6149-470e-ba99-e07ddfaf74e1
# ╟─b84af093-7737-4250-9777-c6d37a7a6bc1
# ╟─a7b9de96-b0ef-432d-8e8c-410916f900b1
# ╟─2614ee96-20c6-459c-b599-1891bbb644b5
# ╟─1814c337-2379-466c-97df-dbee6362ce5c
# ╟─630a7f0f-b5df-496e-a4c7-4c7d3debf8bd
# ╟─65bb64e2-194b-41b5-8228-afc90c165497
# ╠═47fead9c-9bca-49db-984c-20988edd562c
# ╟─32661546-6615-4782-93dd-94cc18554e37
# ╠═b9589e8f-71c5-4d52-805d-d745d778bcc7
# ╠═e1e100c6-5f85-4c73-bd93-f8d5fca6d0ff
# ╠═33092efb-687e-4601-8a5b-92ce52a85ea1
# ╠═891ce1f8-efd7-4fcb-ac98-516c2fb01398
# ╠═51a426b8-5ab7-4887-8ae5-f9f153324efe
# ╠═6ebb149b-9f16-4615-ba23-7e01d8d9e46b
# ╠═9eee6aa0-4710-444e-b320-953c3b4277cf
# ╠═c049e7b0-f3c4-4ee9-a699-f941e5970405
# ╠═324a0b89-f160-42b3-88b4-ce7e27298236
# ╠═efd5cdf5-7961-4747-8a2e-307f6aba60f3
# ╠═8c68f965-493b-4465-941c-9cd10629de2d
# ╠═cafbc4ef-a007-4588-ba30-ff0fceae19ae
# ╠═e410a3d8-7f8b-46ab-988b-06432bf9c5bd
# ╠═9c093d57-dffc-45ef-a3bc-68b69ab17e80
# ╟─02d38202-ef44-44d3-8780-edd3217c3133
# ╠═8a2f5a79-3229-4a73-afa3-70cfe0666e65
# ╠═fbba6ab9-3339-4d3f-964b-81e4f625f7e9
# ╠═a6d3bd52-5228-42eb-9a1c-f99bccd4951e
# ╠═2a960f22-0d11-49fe-9f4b-db5a21afcdec
# ╠═3f2521e9-81ac-4bb9-8c74-e1961c090e50
# ╠═6f0d1339-d1f2-4344-bb5a-465ab2a49300
# ╟─b59871d8-0ce1-4bbd-b698-b461ffef5561
# ╠═7a8a9af0-2f7a-4282-b1df-ef5aea865a41
# ╠═f747b27a-658a-4692-9e8b-ec4bdf40f1aa
# ╠═fcd90d06-bce5-442f-89a4-d049a1b3c826
# ╠═22ec7170-ed1c-4d92-9a30-c6b9cab84bca
# ╠═a046bd56-40a7-4130-bbb4-2ed28ee9d103
# ╠═55e31504-27ae-427d-92d5-0e942c9bb8e5
# ╠═97c70ec5-93b7-4503-9de9-67db304d3eb7
# ╠═e4498937-6b26-4e74-a66c-94f74694f5b7
# ╠═cd4e9a48-eee4-4d0d-b0f9-5359bf92041f
# ╟─19b06d54-72c1-423c-9039-446fee67aed5
# ╠═fa88b54f-2e74-474d-a772-e252ac29794d
# ╠═de3078e6-7102-4e73-aff2-93a2835967d6
# ╟─fd5f7245-e21e-4cbd-a15e-41609de683e1
# ╟─ea4939cc-cdac-4c36-9b57-7c3100fc1e2e
# ╠═edc198d0-95ff-4eea-a0d4-57336092bfaf
# ╠═03aed7c0-dc38-45dd-b965-01316bfdf947
# ╠═d181b7c8-9f69-4786-b643-4a2d0aa14f3e
# ╠═19b8232d-16e1-4b22-805e-16ffc17c9ae0
# ╟─6a4fbd54-d5f2-4cc1-a58a-6d28a535de1a
# ╠═f15bf377-6b8c-4b53-8b9f-ec438144ff9b
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
