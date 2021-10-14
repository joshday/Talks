### A Pluto.jl notebook ###
# v0.14.7

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

# ╔═╡ e44aa366-d8dd-11eb-0706-7d8ad0879e21
begin
	using PlutoUI
	
	md"""
	# Pluto in Production
	
	$(PlutoUI.TableOfContents())
	
	- **Josh Day**, Senior Research Scientist at Julia Computing
	
	"""
end

# ╔═╡ d33edd70-4005-40a7-b135-ef779df55cb7
begin 
	using RDatasets, StatsPlots, OnlineStats, CategoricalArrays, Dates
	dataset_ui = @bind dataset Select(RDatasets.datasets("ggplot2").Dataset)
	md"""
	- Choose a Dataset: $dataset_ui
	"""
end

# ╔═╡ 56f0276e-86fb-476f-a65b-4a5b9376f7bf
md"""
## 1. Motivation

- I'm often developing software to be used by non-programmers. 
  - User workflow is typically:
    1. Load data. 
    2. Do something with data.
- I *could* make a web app with [Dash.jl](https://github.com/plotly/Dash.jl) or [Genie.jl](https://genieframework.com)
- **But**, there's *a lot* more overhead compared to making a notebook.

#### Pros and Cons

- Pluto can look like a web app (with the help of some CSS).
- **But**, each user needs to know how to run their own Pluto server.

"""

# ╔═╡ 0fdbba10-bf28-4386-8528-86bbe5bc7116
md"""
## 2. Web App-ification of Pluto

- Activate CSS? $(@bind css CheckBox())
- We can hide all HTML elements that allow users to interact with code. 
"""

# ╔═╡ e0145853-bd98-447c-aabf-7649547c9400
md"## 3. Common Patterns"

# ╔═╡ e8e1bb0c-388b-4c9b-9eee-3acec0f73851

md"""
##### 3.1 Define the `@bind`-ed variables ahead of output.

- Cleans up `md` blocks.
- Easier to work with many options at once.

```julia
var_ui = @bind var Select(["one","two"])

md"One or two? $var_ui"
```
"""

# ╔═╡ 0f5101eb-7254-4e98-aab4-6077401a6956
md"""
##### 3.2 Give users **information** (not broken cells!).

- I use a few small "logging" functions.
- `try`/`catch` is your friend.
"""

# ╔═╡ 3e7c53d3-4b9f-437a-8bbc-bab1785531fe
begin
	function msg(m, color, bg, icon)
		style="style='color:$color;background:$bg;padding:5px;font-size:20px'"
		HTML("<div $style class=\"markdown\"><p>$icon $m</p></div>")
	end
	success(m) = msg(m, "#047857", "#A7F3D0", "✔")
	err(m) = msg(m, "#B91C1C", "#FEE2E2", "✗")
	warn(m) = msg(m, "#B45309", "#FEF3C7", "⚠")
	info(m) = msg(m, "#1D4ED8", "#DBEAFE", "ⓘ")
end;

# ╔═╡ 114f898b-20a9-41c9-9004-6a78d7cde645
css ? HTML("""
	<style>
		#at_the_top, #info, pluto-helpbox, pluto-shoulder, button.add_cell, .runtime, .delete_cell, pluto-runarea {
	 		visibility: hidden !important;
		}
		.CodeMirror {
			display: none !important;
		}
	</style>
	
	$(success("Custom CSS activated.").content)
	""") :
	warn("Custom CSS is not activated.")

# ╔═╡ c2434639-afd1-4dee-bcb0-104e8a3edbe9
md"Break the code? $(@bind break_it CheckBox())"

# ╔═╡ 68fa9ca6-9faf-4129-a8df-5f06ea162de4
try 
	break_it && error("Oops, the developer made a mistake")
	success("Cool that worked!")
catch ex
	err("Uh oh.  That did not work: $ex")
end

# ╔═╡ be07a65f-db77-42b3-a787-3b2ff8aaa80b
md"""
##### 3.3 Programatically `@bind` variables

- A little tedious, but possible.

```julia
thing_ui = @bind thing ui_element
```

- You cannot programmatically set `thing`.
- You **can** programmatically set `ui_element`.

"""

# ╔═╡ 1b0c1253-7c41-4081-962c-f28597419399
md"# Demo"

# ╔═╡ 6d6a7808-a593-4ba3-b0a4-28948cb81bca
md"## App Code"

# ╔═╡ f897f681-f2c1-4b37-97d4-9ffd92b8243c
begin 
	struct NoUI end 
	Base.show(io, ::MIME"text/html", ::NoUI) = nothing
	report_ui1(T, df) = "" => NoUI() 
	report_ui2(T, df) = "" => NoUI()
	success("Report Defaults")
end

# ╔═╡ 4e400c12-ec35-4d3d-b733-1729bfd4a758
begin 
	struct Describe end
	
	report_ui1(::Describe, df) = "Fields" => MultiSelect(names(df))
	
	function generate(::Describe, df, var1, var2)
		describe(df[!, var1])
	end
	
	success("Implementation of Report: Describe Data")
end

# ╔═╡ 41b9649e-4212-4055-b771-3e8df7ddb3dd
begin 
	struct Plot end
	
	report_ui1(::Plot, df) = "X" => MultiSelect(names(df))
	report_ui1(::Plot, df) = "Y" => MultiSelect(names(df))
	
	function generate(::Plot, df, var1, var2)
		plot(df[!,var1], df[!,var2])
	end
	
	success("Implementation of Report: Plot Data")
end

# ╔═╡ 7c4c1759-6296-40c7-951b-9ec1ebc07055
begin 
	report_options = Dict(
		"Describe Data" => Describe,
		"Plot Data" => Plot
	)
	
	report_ui = @bind report Select(collect(keys(report_options)))
	
	md"""
	- Choose a Report: $report_ui
	"""
end

# ╔═╡ 5ac4cc2a-09cb-4216-aff9-0c2c3c2d08cb
begin
	df = RDatasets.dataset("ggplot2", dataset)
	label1, ui1 = report_ui1(report_options[report], df)
	label2, ui2 = report_ui2(report_options[report], df)
	md"""
	
	$label1 $(@bind report_option1 ui1)
	$label2 $(@bind report_option2 ui2)

	"""
end

# ╔═╡ Cell order:
# ╟─e44aa366-d8dd-11eb-0706-7d8ad0879e21
# ╟─56f0276e-86fb-476f-a65b-4a5b9376f7bf
# ╟─0fdbba10-bf28-4386-8528-86bbe5bc7116
# ╟─114f898b-20a9-41c9-9004-6a78d7cde645
# ╟─e0145853-bd98-447c-aabf-7649547c9400
# ╟─e8e1bb0c-388b-4c9b-9eee-3acec0f73851
# ╟─0f5101eb-7254-4e98-aab4-6077401a6956
# ╠═3e7c53d3-4b9f-437a-8bbc-bab1785531fe
# ╟─c2434639-afd1-4dee-bcb0-104e8a3edbe9
# ╠═68fa9ca6-9faf-4129-a8df-5f06ea162de4
# ╟─be07a65f-db77-42b3-a787-3b2ff8aaa80b
# ╟─1b0c1253-7c41-4081-962c-f28597419399
# ╟─d33edd70-4005-40a7-b135-ef779df55cb7
# ╟─7c4c1759-6296-40c7-951b-9ec1ebc07055
# ╠═5ac4cc2a-09cb-4216-aff9-0c2c3c2d08cb
# ╟─6d6a7808-a593-4ba3-b0a4-28948cb81bca
# ╟─f897f681-f2c1-4b37-97d4-9ffd92b8243c
# ╟─4e400c12-ec35-4d3d-b733-1729bfd4a758
# ╟─41b9649e-4212-4055-b771-3e8df7ddb3dd
