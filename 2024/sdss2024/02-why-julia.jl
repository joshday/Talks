### A Pluto.jl notebook ###
# v0.20.8

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 57c19f11-d09a-4d5f-8905-533e4192f6a5
begin
	using Cobweb: Cobweb, h
	using PlutoUI
	using Distributions
	using BenchmarkTools
	using PlotlyLight
	img(src, style="") = h.img(; src, style="border-radius:8px;$style")
	md"""
	(notebook setup)
	$(PlutoUI.TableOfContents())
	$(HTML("<style>h1 { padding-top: 200px; }</style>"))
	$(HTML("<style>h2 { padding-top: 100px; }</style>"))
	$(HTML("<style>h3 { padding-top: 50px; }</style>"))
	"""
end

# ╔═╡ 8266f02e-5ccf-49a4-8283-fc7cfe0f8106
using LinearAlgebra

# ╔═╡ 7d084dec-647e-46ba-bd25-eadd9f336295
let
	using AbstractTrees
	
	# Don't do this!  It's piracy!
	# Piracy is defining a method on a type when you "own" neither.
	AbstractTrees.children(T::DataType) = subtypes(T)
	print_tree(Real)
end

# ╔═╡ 96eadd80-13a8-11ef-0d1e-4d6ff384ac8a
md"""
# Why Julia?


## A Personal Perspective

- I'm surprised that Julia has had little traction among statisticians.
- I feel like learning Julia gave me super powers for my computationally-heavy PhD research and I want to share those powers with others.
- I am an R (and Rcpp) convert to Julia.  When making the switch:
  - Code was easier to write.
  - My programs were faster.
  - My code was easier to *read* (less boilerplate).
  - My code was easier to debug (Julia all the way down).
  - I eventually learned the "Julian" way of doing things (more on this later).

!!! note "What is the Best Language?"
	- In many cases, it's the one you already know.  
	- Sometimes long-term gains are worth the short-term struggles of learning something new.
"""

# ╔═╡ bb9083eb-be2f-4fef-aa3e-27b44045a107
let
	x = 1:100;
	y1 = 50 .+ x;
	y2 = 5 .+ 2x;
	p = plot.scatter(; x=x, y=y1, mode="lines", name="Something I Already Know").scatter(;x=x, y=y2, mode="lines", name="Julia")
	p.layout.xaxis = Config(showticklabels=false, zeroline=false, title="Time")
    p.layout.yaxis = Config(showticklabels=false, zeroline=false, title="Productivity")
	p
end

# ╔═╡ ef4b6a7f-9925-4c1a-a969-645a5f3b4852
md"""
## What do the Creators of Julia Say?

!!! note "From \"Why We Created Julia\" Blog Post"
	> We are greedy: we want more.
	>
	> We want a language that's open source, with a liberal license. We want the speed of C with the dynamism of Ruby. We want a language that's homoiconic, with true macros like Lisp, but with obvious, familiar mathematical notation like Matlab. We want something as usable for general programming as Python, as easy for statistics as R, as natural for string processing as Perl, as powerful for linear algebra as Matlab, as good at gluing programs together as the shell. Something that is dirt simple to learn, yet keeps the most serious hackers happy. We want it interactive and we want it compiled.
	>
	> - ["Why We Created Julia"](https://julialang.org/blog/2012/02/why-we-created-julia/)

	
"""

# ╔═╡ b6f69a22-9dba-476b-8c7f-c31f15ce1946
md"""
# Three Claims About Julia

As we continue through the workshop, I'd like you to keep these claims in mind.
"""

# ╔═╡ 9ad1bbc7-99cd-4b02-ad06-ad9a01754372
md"""
## Claim 1

!!! highlight "Julia Solves the \"Two-Language Problem\""

	!!! note "The Two-Language Problem"
		1. You write **prototype** code in an *easy* language.
		2. You write **production** code in a *fast* language.

	#### Example
	1. I've written a script to verify my new approach works.
	2. Now I'm going to release my algorithm to the world in a package.
	
	#### Evidence
	- Most Julia packages are 100% Julia!
	- User-defined functions are **no different** than built-in functions.
	- Much of Julia is written...in Julia.
"""

# ╔═╡ 094c96c9-3d95-45f4-b2fb-e2d2d19a2282
md"""
## Claim 2

!!! highlight "Julia Solves the \"Two-Culture Problem\""

	![](https://user-images.githubusercontent.com/8075494/240981379-459fe8b7-7bc7-4652-ab79-889c32221225.png)
	
	![](https://user-images.githubusercontent.com/8075494/240981352-5824c33a-1a87-4213-8585-d53df2bfbb25.png)

	- Images borrowed from [https://scientificcoder.com/my-target-audience](https://scientificcoder.com/my-target-audience)

	> If you work with just one other person, you've experienced this at some level.

	!!! info "For Academics:"
		In Academia, "bring ideas to production" could simply mean "I want my simulations to run in an hour, not over the weekend"
"""

# ╔═╡ 371ebe30-b801-48f3-9c44-2d208fd9c84d
md"""
## Claim 3

!!! highlight "Learning Julia Changes how You Solve Problems with Code"

	!!! note "The Sapir-Whorf Hypothesis"
		> The particular language one speaks influences the way one thinks about reality.
		> - [https://www.sciencedirect.com/topics/psychology/sapir-whorf-hypothesis](https://www.sciencedirect.com/topics/psychology/sapir-whorf-hypothesis)

	!!! note "Programming Language Interpretation of Sapir-Whorf"
		> Your language influences how you solve problems.


	###### Combining ideas from claims 2 and 3:

	> I'm going to use a hypothetical language called Blub...
	> 
	> As long as our hypothetical Blub programmer is looking down the power continuum, they know they're looking down. Languages less powerful than Blub are obviously less powerful, because they're missing features our programmer is used to. But **when our programmer looks up the power continuum, they don't realize they're looking up. What they see are merely weird languages.** They probably consider them about equivalent in power to Blub, but with all this other hairy stuff thrown in as well. Blub is good enough for them, because they think in Blub.
	> - Paraphrased from Paul Graham's ["Beating the Averages" Essay](http://www.paulgraham.com/avg.html) (emphasis added)
"""

# ╔═╡ bc4d8ba5-dc50-435f-9b60-54093a4d3c87
md"""
!!! note "Personal Note"
	- It took *months* to allow myself to write for-loops when switching from R to Julia.
	- A large part of a programming language's influence on you is where it places restrictions on performance.
	  - E.g. if loops are slow you avoid loops.
"""

# ╔═╡ 18183560-b603-4d1d-9b62-f905c41025ae
md"""
# Julia Highlights
"""

# ╔═╡ 87c653d0-2c37-404f-b4ca-9baa0e631342
md"""
## Performance

$(img("https://julialang.org/assets/images/benchmarks.svg", "background:white"))
"""

# ╔═╡ 7f5370e1-ba7d-44f9-8006-8dc6d3b91ed2
md"""
!!! success "Quick Story"
	- At my first JuliaCon (2016), I saw Doug Bates (of `lme4` fame) give a 10 minute lightning talk about `MixedModels.jl`.
	- He'd translated a model from R to Julia that took "most of the day" to fit  in his "best-written R code".
	- He coded live and fit the model within his 10 minute talk.
"""

# ╔═╡ 6cfd0add-04a0-49c5-bfb3-ca5219f8fde2
md"""
## Automatic Specialization

!!! note "Julia uses a Just-in-time (JIT) compiler: LLVM"
	

	- Start with a simple function:
	```julia
	f(x, y) = x + y
	```

	- `f(1, 2)` will compile a *method* for `f(::Int,::Int)`
	- `f(1.0, 2.0)` will compile a *method* for `f(::Float64, ::Float64)`
	- The next time you call a compiled method you don't need to recompile it, e.g. `f(4,5)`.
"""

# ╔═╡ 2fdeddbc-90ad-4fb3-8c1c-44846fc5dd1b
md"""
!!! info "Specialized code \"for free\""
	You get *specialized* code without telling Julia about the types of inputs.
"""

# ╔═╡ f16cf76f-b633-4b07-949b-9d7470e6a474
f(x, y) = x + y

# ╔═╡ c27cf96f-d020-441c-b67a-6fe70381f3ff
@code_llvm f(1, 1)

# ╔═╡ 7d36652e-12da-453f-baaa-1adbcbaf01d9
@code_llvm f(1.0, 1.0)

# ╔═╡ 238de788-2786-4857-ab43-521511bd08d7
md"""
## Multiple Dispatch

!!! note "Note: Dispatch and Multiple Dispatch"
    - **Dispatch** is the choice of which method to execute when a function is applied. 
	- **Multiple Dispatch** is dispatch based on the types of *all* arguments to a function.
	- **Single Dispatch** uses one argument to decide which method to call.
"""

# ╔═╡ 5159aafe-93f0-4b4d-9140-c7e9bc806b86
md"""
### Example: Matrix-Vector Product with `Diagonal`
"""

# ╔═╡ 88bfb17d-a14e-40dc-85e1-b120530ea2ef
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

# ╔═╡ 988aa4fc-9a2a-4903-b5e4-ef70086e98a2
md"""
!!! note "How does this work?"
	- The `*(::Diagonal, ::Vector)` method is faster than the `*(::Matrix, ::Vector)` method.
"""

# ╔═╡ 9095d354-1afa-450a-a756-31f4b5bcf002
md"""
!!! note "Case Study: How MixedModels.jl uses Multiple Dispatch"
	#### MixedModels.jl takes great advantage of this!

	##### Design Matrices in Mixed Models Often Have Structure
	- Block diagonal
	- Block sparse 

	##### Algorithms are Reused for Any Matrix Structure
	- Single implementation relying on `*`, `+`, etc.
	- Providing different `AbstractMatrix` types as the inputs will "just work".
	  - e.g. `SparseMatrix` from SparseArrays.jl, `BlockMatrix` from BlockArrays.jl, etc.
"""

# ╔═╡ f26b1605-46e8-4df3-b94b-972508c6a7a2
md"""
!!! note "Related: Julia Packages are Often "Composable\""
	- i.e. they work together without an explicit dependency.
	- Only true if algorithms are "sufficiently abstract".

	##### Example
	- You write a function `f(x::AbstractMatrix)`.
	- Now you realize your input is a block matrix, so you use **BlockArrays.jl** for a free speedup.
"""

# ╔═╡ ad895c04-2c8d-4862-88fe-dca1055f69a3
md"""
### Example: Specialization + Multiple Dispatch
"""

# ╔═╡ 3f48fc0c-3dd9-496c-8df0-536e72fc158f
md"""
!!! note "A more complicated example (think about Sapir-Worf)"

	Finding quantiles with Newton's Method for finding roots:
	
	$$\text{Solve for } x \text{:}\quad F_X(x) - q= 0$$
	
	- where $F_X$ is CDF of random variable $X$.
	
	$$x_{n+1} = x_n - \frac{F_X(x_n) - q}{F_X'(x_n)}$$

"""

# ╔═╡ fe550b68-e7f5-4a0c-8e30-b837c347c5a4
md"""
!!! note "What methods does my implementation need?"
	- `mean(dist)` 
	- `cdf(dist, x)`
	- `pdf(dist, x)`
"""

# ╔═╡ 1b482b30-e75e-4ef2-b96d-97f7e8763298
function myquantile(dist, q)
    x = mean(dist)
    for i in 1:25
        x -= (cdf(dist, x) - q) / pdf(dist, x)
    end
    x
end

# ╔═╡ 91d68777-1ff1-4117-9074-f9e294160fd7
md"""
#### Does it Work?

$(@bind dist Select([nothing, Normal(), Gamma(5,1), Uniform(0,1), Beta(7,2)]))
"""

# ╔═╡ 964cf9d5-13f0-4b30-940c-90fade5f9649
let
	rng = 0.01:.01:.99
	if isnothing(dist) 
		nothing 
	else
		@show myquantile(dist, 0.5)
		@show quantile(dist, 0.5)
		p = Plot()(
			y=rng, x=quantile.(dist, rng), name="quantile"
		)(
			y=rng, x=myquantile.(dist, rng), line=(;dash="dot"),
			name="myquantile"
		)
		p.layout.title=string(dist)
		p.layout.xaxis.title = "x"
		p.layout.yaxis.title = "P(X) < x"
		p
	end
end

# ╔═╡ 66fe2e95-ed0a-4f59-ad68-1623bf0f4a05
md"""
!!! note "How Would You Implement This in R?"
	You would need to re-implement it for every distribution using the `dnorm`/`pnorm` family of functions.
"""

# ╔═╡ 843ca6ac-e4ce-412e-ba78-10b367327eb1
md"""
## Type System

We've already been introduced to the type system via specialization/multiple dispatch.  Here we'll go into more depth on how it works.

- **Abstract** types don't "exist", but define a set.
- **Concrete** types "exist".

!!! note "Types: Think Sets"
	Using an abstract type in a type annotation, `f(::Real)`, indicates:

	> this function works with any real number.
"""

# ╔═╡ b8eb79d7-bf59-4079-91e7-2fe4408260d7
md"#### Subtypes of `Real`:"

# ╔═╡ 9b58ea34-e666-471d-b84d-94d514cf2efe
md"""
!!! info "Type Annotations (::)"
	*Type Annotations* do not affect performance (because of Julia's automatic specialization). e.g.

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

# ╔═╡ ac8f182c-82af-43fb-b2ce-5ff421b97fa3
begin 
	half(x::Number) = x / 2 

    half(x) = x[1:floor(Int, length(x) / 2)]

	@show half(1)
	@show half(1 + 2im)
	@show half("ABCDEFG")
	@show half(1:10)
end;

# ╔═╡ 9660dbe9-a147-4f2d-8500-c77faa3516dc
md"""
## Broadcasting

- Eliminates temporary arrays!
- Makes operations more explicit at the cost of one character.


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

	# But...most people will write the first one
	```
"""

# ╔═╡ 1daa49d8-92f4-43a8-8b89-28ff09b7e89d
@benchmark abs.(sin.(sqrt.(1:1000 .+ 10)))

# ╔═╡ 0f2896d2-4a00-4d66-85c8-4b30e60db1cd
@benchmark begin
	temp1 = 1:1000 .+ 10
	temp2 = sqrt.(temp1)
	temp3 = sin.(temp1)
	abs.(temp3)
end

# ╔═╡ 3991c42e-5a89-4b5a-b909-cfc28dc0d21c
md"""
## Metaprogramming (Macros)

!!! note "What is a Macro?"
	A function of an *expression* .  Macros can change an expression before it gets evaluated.

	- Julia expressions are **represented in Julia (`Expr`)**.

	```julia
	@mymacro 1 + 2
	```

	- `@mymacro`'s input here is `Expr(:call, :+, 1, 2)`
"""

# ╔═╡ 78aadb77-bdf6-4862-992e-4e435df29950
let 
	ex = Meta.parse("1 + 1")
	@info ex.head  # :call
	@info ex.args  # [:+, 1, 1]
end

# ╔═╡ 885fa73e-7266-4e13-9818-e50cd0094089
# Change second argument of infix operator to `100`
macro mymacro(ex)
	ex.args[end] = 100
	return ex
end

# ╔═╡ 3fb32a5f-bb1c-499c-b72b-9e42871451da
@mymacro 1 + 2

# ╔═╡ a0c915c1-d620-4e92-b61a-057766800d26
@mymacro 2 * "This will get replaced"

# ╔═╡ eda7707e-1e1d-42a1-af20-c82cf39066d6
md"""
!!! note
	R's "Non-standard evaluation" makes every function macro-like.
"""

# ╔═╡ ac61cf71-b30a-48e5-a8fc-c08944e8426f
md"""
## Mutation

!!! note "\"Pass by Sharing\""
	In Julia, function arguments are passed "by sharing" (AKA "by reference") and a function can change the value of an argument.  By convention, mutating functions end with `!`. 

	Note that in R, arguments are passed "by copy", with the exception of a few special data types.
"""

# ╔═╡ e838f6bf-0e3a-43ce-a791-74ecc6b22b5e
let 
	x = [1, 2]
	
	push!(x, 3)  # Add `3` to the end
	
	popfirst!(x)  # Remove `1` from the start
	
	x
end

# ╔═╡ bdb16f98-57be-425e-99c8-6f02ccf14475
md"""
- In-place operations sometimes provide big performance gains.
"""

# ╔═╡ 782eaf00-f0b0-4f9d-a77d-df38108d4952
md"""
!!! aside "Function Names Ending in `!` is a *Convention*"
	- There's nothing special about adding `!` to a function name.  
	- It is merely a convention that provides a hint to the user.
"""

# ╔═╡ fb4b17e9-0669-40d9-a53a-6538bb46b04e
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

# ╔═╡ f04dbab7-b08b-48c3-a0ea-559de323a800
md"""
## Usability

!!! note "Quality of Life Features"
	Julia has many "minor" features that help make it a joy to code in.
"""

# ╔═╡ 909ca104-01ee-42b8-ba2f-350e4cf6ebaa
md"""
### Tab Autocompletion

!!! aside "What Autocompletes?"
	In many cases, the tab key will autocomplete what you're typing (in coding environments like Pluto or the REPL):

	- Property names (dot syntax).
	- Dictionary keys.
	- File/directory paths.
	- Greek letters.
"""

# ╔═╡ 23644f93-7b0a-476b-988b-6d559c50b03e
nt = (x=1, y=2, property_with_a_really_long_name=3)

# ╔═╡ ef1aa424-bee9-4254-91b1-cf30b2d2615b
# Type this below: nt.p <TAB>
nt.property_with_a_really_long_name

# ╔═╡ 8a13f30a-5d44-4565-bd16-3c030f7ac45e
dict = Dict("one" => 1, "two" => 2)

# ╔═╡ ec1af15a-ed47-4d59-b4f6-269cfe8216a4
# Type this below: dict["t <TAB>


# ╔═╡ 0f515f6d-4eae-44bd-9a09-693383e9efec
# Type this below: \rho <TAB>


# ╔═╡ c9a2da69-c872-4b0c-a1e1-4d6bf544195c
# Type this below: \:smile: <TAB>
😄 = 1

# ╔═╡ 1da39bb0-241f-4498-aafd-3c8594e3cfae
md"""
### Anonymous Functions

!!! aside "What's an Anonymous Function?"
	Anonymous functions are one-off functions that are typically passed as an argument to some other function.  There are three ways to write them.

	---

	The `do` block syntax is only available when *the first argument* is a function.

	---

	The following three syntaxes are equivalent:
"""

# ╔═╡ d5d4d951-6bfa-484d-9a7f-8873c6c58ab5
map(x -> x + 1, 1:5)

# ╔═╡ 135103d3-ab4d-4d49-ae39-93a0e9a4c638
map(function(x) x + 1 end, 1:5)

# ╔═╡ e9771229-00ae-4dc1-a998-712c783dfe9d
map(1:5) do x 
	x + 1
end

# ╔═╡ c9d67cef-497e-4e01-b894-72ae5d6cc010
md"""
### Generators

!!! aside "What are Generators?"
	- Generators *generate* an iterator.
	- Most functions that you typically think of being used with an array will accept arbitrary iterators, including generators.
"""

# ╔═╡ 0d17bf6a-b1f4-473d-8bcb-54068e1df757
let 
	g = (x for x in 1:10 if x > 8)

	sum(g)  # == 9 + 10
end

# ╔═╡ a96a3d39-c79a-4215-ba15-8693da129cd7
md"""
### Array Comprehensions

!!! aside "What are Array Comprehensions?"
	- Array comprehensions are for programmatically creating the values of an array.
	- Essentially take a generator and wrap an array around it.

	---

	Below are a few use cases for statisticians:
"""

# ╔═╡ 528f234f-415e-4d8e-87c4-1f012ff74dca
ρ = 0.5

# ╔═╡ 05e6f883-5899-43be-8b7d-3e9651ab9df0
# Exponential Decay
exp_decay = [exp(-ρ * t) for t in 1:10]

# ╔═╡ e91237b1-adba-4e6c-b480-309a9a690ee8
# Weights of Exponentially Weighted Mean
ewma_weights = [ρ * (1 - ρ) ^ (t-1) for t in 1:10]

# ╔═╡ a207e5bd-4710-40ee-b9e0-4d16fa3230ad
# AR(1) correlation matrix
ar1 = [ρ ^ abs(i - j) for i in 1:10, j in 1:10]

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AbstractTrees = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
Cobweb = "ec354790-cf28-43e8-bb59-b484409b7bad"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
PlotlyLight = "ca7969ec-10b3-423e-8d99-40f33abb42bf"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
AbstractTrees = "~0.4.5"
BenchmarkTools = "~1.5.0"
Cobweb = "~0.6.1"
Distributions = "~0.25.108"
PlotlyLight = "~0.9.1"
PlutoUI = "~0.7.59"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.5"
manifest_format = "2.0"
project_hash = "f5325b1a9ce03e6256891dffa122e15c547091d0"

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
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "f1dff6729bc61f4d49e140da1af55dcd1ac97b2f"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.5.0"

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
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "4e1fe97fdaed23e9dc21d4d664bea76b65fc50a0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.22"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.DefaultApplication]]
deps = ["InteractiveUtils"]
git-tree-sha1 = "c0dfa5a35710a193d83f03124356eef3386688fc"
uuid = "3f0dd361-4fe0-5fc6-8523-80b14ec94d85"
version = "1.1.0"

[[deps.Distributions]]
deps = ["AliasTables", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns"]
git-tree-sha1 = "3e6d038b77f22791b8e3472b7c633acea1ecac06"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.120"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"
    DistributionsTestExt = "Test"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.DocStringExtensions]]
git-tree-sha1 = "e7b7e6f178525d17c720ab9c081e4ef04429f860"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.4"

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
version = "1.11.0"

[[deps.FillArrays]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "6a70198746448456524cb442b8af316927ff3e1a"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.13.0"
weakdeps = ["PDMats", "SparseArrays", "Statistics"]

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.HypergeometricFunctions]]
deps = ["LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "68c173f4f449de5b438ee67ed0c9c748dc31a2ec"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.28"

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
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "e2222959fbc6c19554dc15174c81bf7bf3aa691c"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.4"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "a007feb38b422fbdab534406aeca1b86823cb4d6"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.7.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "PrecompileTools", "StructTypes", "UUIDs"]
git-tree-sha1 = "196b41e5a854b387d99e5ede2de3fcb4d0422aae"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.14.2"

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
version = "8.6.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "13ca9e2586b89836fd20cccf56e57e2b9ae7f38f"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.29"

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
version = "1.11.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.5+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1346c9208249809840c91b26703912dff463d335"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.6+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "cc4054e898b852042d7b503313f7ad03de99c3dd"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "f07c06228a1c670ae4c87d1276b92c7c597fdda0"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.35"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "7d2f8f21da5db6a806faf7b9b292296da42b2810"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.3"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PlotlyLight]]
deps = ["Artifacts", "Cobweb", "Downloads", "EasyConfig", "JSON3", "REPL", "Random", "StructTypes"]
git-tree-sha1 = "e1fe53fe70a5238eebf6f64f285a794ff2da5a3b"
uuid = "ca7969ec-10b3-423e-8d99-40f33abb42bf"
version = "0.9.2"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "d3de2694b52a01ce61a036f18ea9c0f61c4a9230"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.62"

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
version = "1.11.0"

[[deps.Profile]]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"
version = "1.11.0"

[[deps.PtrArrays]]
git-tree-sha1 = "1d36ef11a9aaf1e8b74dacc6a731dd1de8fd493d"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.3.0"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "9da16da70037ba9d701192e27befedefb91ec284"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.11.2"

    [deps.QuadGK.extensions]
    QuadGKEnzymeExt = "Enzyme"

    [deps.QuadGK.weakdeps]
    Enzyme = "7da242da-08ed-463a-9acd-ee780be4f1d9"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "852bd0f55565a9e973fcfee83a84413270224dc4"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.8.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "58cdd8fb2201a6267e1db87ff148dd6c1dbd8ad8"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.5.1+0"

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
version = "1.11.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.11.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "41852b8679f78c8d8961eeadc8f62cef861a52e3"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.5.1"

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

    [deps.SpecialFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["AliasTables", "DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "b81c5035922cc89c2d9523afc6c54be512411466"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.5"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "8e45cecc66f3b42633b8ce14d431e8e57a3e242e"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.5.0"

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

    [deps.StatsFuns.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "159331b30e94d7b11379037feeb9b690950cace8"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.11.0"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.7.0+0"

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
version = "1.11.0"

[[deps.Tricks]]
git-tree-sha1 = "6cae795a5a9313bbb4f60683f7263318fc7d1505"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.10"

[[deps.URIs]]
git-tree-sha1 = "cbbebadbcc76c5ca1cc4b4f3b0614b3e603b5000"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╠═57c19f11-d09a-4d5f-8905-533e4192f6a5
# ╟─96eadd80-13a8-11ef-0d1e-4d6ff384ac8a
# ╠═bb9083eb-be2f-4fef-aa3e-27b44045a107
# ╟─ef4b6a7f-9925-4c1a-a969-645a5f3b4852
# ╟─b6f69a22-9dba-476b-8c7f-c31f15ce1946
# ╠═9ad1bbc7-99cd-4b02-ad06-ad9a01754372
# ╠═094c96c9-3d95-45f4-b2fb-e2d2d19a2282
# ╠═371ebe30-b801-48f3-9c44-2d208fd9c84d
# ╟─bc4d8ba5-dc50-435f-9b60-54093a4d3c87
# ╟─18183560-b603-4d1d-9b62-f905c41025ae
# ╠═87c653d0-2c37-404f-b4ca-9baa0e631342
# ╟─7f5370e1-ba7d-44f9-8006-8dc6d3b91ed2
# ╟─6cfd0add-04a0-49c5-bfb3-ca5219f8fde2
# ╟─2fdeddbc-90ad-4fb3-8c1c-44846fc5dd1b
# ╠═f16cf76f-b633-4b07-949b-9d7470e6a474
# ╠═c27cf96f-d020-441c-b67a-6fe70381f3ff
# ╠═7d36652e-12da-453f-baaa-1adbcbaf01d9
# ╟─238de788-2786-4857-ab43-521511bd08d7
# ╟─5159aafe-93f0-4b4d-9140-c7e9bc806b86
# ╠═8266f02e-5ccf-49a4-8283-fc7cfe0f8106
# ╠═88bfb17d-a14e-40dc-85e1-b120530ea2ef
# ╟─988aa4fc-9a2a-4903-b5e4-ef70086e98a2
# ╟─9095d354-1afa-450a-a756-31f4b5bcf002
# ╟─f26b1605-46e8-4df3-b94b-972508c6a7a2
# ╟─ad895c04-2c8d-4862-88fe-dca1055f69a3
# ╠═3f48fc0c-3dd9-496c-8df0-536e72fc158f
# ╟─fe550b68-e7f5-4a0c-8e30-b837c347c5a4
# ╠═1b482b30-e75e-4ef2-b96d-97f7e8763298
# ╟─91d68777-1ff1-4117-9074-f9e294160fd7
# ╟─964cf9d5-13f0-4b30-940c-90fade5f9649
# ╟─66fe2e95-ed0a-4f59-ad68-1623bf0f4a05
# ╟─843ca6ac-e4ce-412e-ba78-10b367327eb1
# ╟─b8eb79d7-bf59-4079-91e7-2fe4408260d7
# ╠═7d084dec-647e-46ba-bd25-eadd9f336295
# ╠═9b58ea34-e666-471d-b84d-94d514cf2efe
# ╠═ac8f182c-82af-43fb-b2ce-5ff421b97fa3
# ╟─9660dbe9-a147-4f2d-8500-c77faa3516dc
# ╠═1daa49d8-92f4-43a8-8b89-28ff09b7e89d
# ╠═0f2896d2-4a00-4d66-85c8-4b30e60db1cd
# ╟─3991c42e-5a89-4b5a-b909-cfc28dc0d21c
# ╠═78aadb77-bdf6-4862-992e-4e435df29950
# ╠═885fa73e-7266-4e13-9818-e50cd0094089
# ╠═3fb32a5f-bb1c-499c-b72b-9e42871451da
# ╠═a0c915c1-d620-4e92-b61a-057766800d26
# ╟─eda7707e-1e1d-42a1-af20-c82cf39066d6
# ╠═ac61cf71-b30a-48e5-a8fc-c08944e8426f
# ╠═e838f6bf-0e3a-43ce-a791-74ecc6b22b5e
# ╟─bdb16f98-57be-425e-99c8-6f02ccf14475
# ╠═782eaf00-f0b0-4f9d-a77d-df38108d4952
# ╠═fb4b17e9-0669-40d9-a53a-6538bb46b04e
# ╟─f04dbab7-b08b-48c3-a0ea-559de323a800
# ╟─909ca104-01ee-42b8-ba2f-350e4cf6ebaa
# ╠═23644f93-7b0a-476b-988b-6d559c50b03e
# ╠═ef1aa424-bee9-4254-91b1-cf30b2d2615b
# ╠═8a13f30a-5d44-4565-bd16-3c030f7ac45e
# ╠═ec1af15a-ed47-4d59-b4f6-269cfe8216a4
# ╠═0f515f6d-4eae-44bd-9a09-693383e9efec
# ╠═c9a2da69-c872-4b0c-a1e1-4d6bf544195c
# ╟─1da39bb0-241f-4498-aafd-3c8594e3cfae
# ╠═d5d4d951-6bfa-484d-9a7f-8873c6c58ab5
# ╠═135103d3-ab4d-4d49-ae39-93a0e9a4c638
# ╠═e9771229-00ae-4dc1-a998-712c783dfe9d
# ╟─c9d67cef-497e-4e01-b894-72ae5d6cc010
# ╠═0d17bf6a-b1f4-473d-8bcb-54068e1df757
# ╟─a96a3d39-c79a-4215-ba15-8693da129cd7
# ╠═528f234f-415e-4d8e-87c4-1f012ff74dca
# ╠═05e6f883-5899-43be-8b7d-3e9651ab9df0
# ╠═e91237b1-adba-4e6c-b480-309a9a690ee8
# ╠═a207e5bd-4710-40ee-b9e0-4d16fa3230ad
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
