# Julia for Technical Computing
### Josh Day
### https://github.com/joshday
### jtday2@ncsu.edu

---
# Overview
- What is Julia?

---
# What is Julia?
> Julia is a high-level, high-performance dynamic programming language for technical computing, with syntax that is familiar to users of other technical computing environments.
- http://julialang.org

---
# Benchmarks
![inline](benchmarks.png)

---
# Julia's growth
![](http://pkg.julialang.org/img/allver.svg)

---
# Julia's growth
![](http://pkg.julialang.org/img/stars.svg)

---
# More than "Fast R" or "Fast Python"
- Julia is fast because of features which work well together
- You can't just take the magic dust that makes Julia fast and apply it to your favorite language

---
# Julia Language Design
- Type system
- Multiple dispatch
- Type inference
- Metaprogramming (macros)
- Just-in-time (JIT) compilation using LLVM
- Clean, familiar syntax

---
# Julia Basics
## Functions
```julia
f(x) = x ^ 2

function f(x)
    x ^ 2
end
```

---
# Julia Basics
## JIT
- live example with `@code_llvm` macro

---
# Julia Basics
## For loops
```julia
for i in 1:3
    println(i)
end
```
Output:
```
1
2
3
```

---
# Type System
- When thinking about types, think about set theory
- *abstract* types define a set of other types
- One abstract type in Julia is `Number`

---
# `Number`
![](tree.png)

---
# `Number`
- What should a `Number` be able to do?
  `+`, `-`, `*`, etc. 
```julia
methods(*)
```
```julia
# 178 methods for generic function "*":
*(x::Bool, z::Complex{Bool}) in Base at complex.jl:225
*(x::Bool, y::Bool) in Base at bool.jl:91
*(x::Bool, y::T) where T<:Unsigned in Base at bool.jl:104
*(x::Bool, z::Complex) in Base at complex.jl:232
*(x::Bool, y::Irrational) in Base at irrationals.jl:105
*(x::Bool, y::T) where T<:Number in Base at bool.jl:101
*(a::Float16, b::Float16) in Base at float.jl:368
*(x::Float32, y::Float32) in Base at float.jl:374
*(x::Float64, y::Float64) in Base at float.jl:375
...
```

---
# Abstraction and Multiple Dispatch
- Consider these three function definitions:
```julia
# Too broad?  Not everything can be added
f(x) = x + x


# Too specific?  Numbers besides Float64 can be added
g(x::Float64) = x + x


# Just right.  Works on the entire type tree thanks to 
# the JIT and type inference
h(x::Number) = x + x
```

---
# Quantile Example
- Suppose I want to find quantiles using Newton's method:
$$\theta_{t+1} = \theta_t - \frac{F(\theta_t) - q}{F'(\theta_t)}$$
  where $F$ is the CDF of a distribution
- In R, I would need a different function for every distribution!
- In Julia, we can do this in one function

---
# The Power of Julia: Abstraction
- Define functions for the "highest" type you can
- Any `UnivariateDistribution` has methods `mean`, `cdf`, and `pdf`
```julia
using Distributions

function myquantile(d::UnivariateDistribution, q::Number)
    θ = mean(d)
    tol = Inf
    while tol > 1e-5
        θold = θ
        θ = θ - (cdf(d, θ) - q) / pdf(d, θ)
        tol = abs(θold - θ)
    end
    θ
end
```

---
```julia
for d in [Normal(), Gamma(5,1), TDist(4)]
    println("For $d")
    println("  > myquantile: $(myquantile(d, .4))")
    println("  > quantile:   $(quantile(d, .4))")
    println()
end
```
```
For Distributions.Normal{Float64}(μ=0.0, σ=1.0)
  > myquantile: -0.2533471031356957
  > quantile:   -0.2533471031357997

For Distributions.Gamma{Float64}(α=5.0, θ=1.0)
  > myquantile: 4.1477358804705435
  > quantile:   4.1477358804705435

For Distributions.TDist{Float64}(ν=4.0)
  > myquantile: -0.27072229470638115
  > quantile:   -0.27072229470759746
```

---
# Julia's Growing Package Ecosystem

---
# Plotting and Graphics
#### Julia does not have a built-in plotting package

- [Plots](https://github.com/JuliaPlots/Plots.jl)
  - Defines a plotting API that can use several "backends"
- [Gadfly](https://github.com/GiovineItalia/Gadfly.jl)
  - Grammar of graphics for Julia
- Others: PyPlot, UnicodePlots, GR, GLPlot, Winston, ...

---
# Plots with PyPlot

```julia
using Plots
pyplot()  # use PyPlot backend
plot(randn(50, 2))
```

![](pyplot2.png)

---
# Plots with GR
```julia
gr()  # use GR backend
plot(randn(50, 2))
```
![](gr.png)


---
# Calling R from Julia
- Side note: REPL modes 
  - `;` (shell mode)
  - `?` (help mode)
- RCall adds
  - `$` (R mode) 
 
```julia
using RCall
R"rnorm(5)"
```

---
# Macros
- Macros are functions of expressions
- They change an expression before it is run
```julia
x = randn(1000);

@time sum(x)  # precompilation at work
#   0.031018 seconds (12.86 k allocations: 602.013 KB)
# -34.195601715147035

@time sum(x)
#   0.000003 seconds (5 allocations: 176 bytes)
# -34.195601715147035
```

---
# Macros
