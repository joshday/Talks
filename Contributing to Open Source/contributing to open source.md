# How to Contribute to Open Source Projects

---
# Git and Julia
- Julia's package manager is based on git
- You can't contribute without some basic knowledge
	- checkout, clone, fork, branch, staging, commit, pull, push


---
# Learn git.  Seriously.
- Steep learning curve, but worth it
- If I throw water on my computer right now, I lose approximately 0% of my work from the last three years


---
# Follow the style of the project you are contributing to
- https://github.com/johnmyleswhite/Style.jl


--- 
# GitHub Issues
- On smaller projects, it's typically okay to ask questions
- On larger projects:
	- **Issues aren't the place for questions (use Discourse)**
	- First search for the same issue (Google/discourse)
	- Make a **minimal reproducible example**

---
# Contributing Workflow
- `git` commands need to be run inside the directory of the package you are changing:

`.julia/v0.6/PackageToChange`

![](https://image.slidesharecdn.com/gittutorial2-141014072059-conversion-gate02/95/git-tutorial-ii-32-638.jpg?cb=1413271537)

---
### Fork the package on GitHub
You need a place to store your changes, because you're not allowed to change someone else's repository.

### On your machine, add a remote
You need to tell git how to push changes to your fork.

`git remote add rname https://github.com/joshday/Repo.git`

### Make changes and save them

This will push any changes you've made

`git commit -am "Added the greatest feature ever"`
`git push rname`


- Make PR (pull request) from GitHub

---
# Making a new package
```
Pkg.add("PkgDev")

using PkgDev

PkgDev.generate("MyPackage", "MIT") 
```

- `generate` sets up your directory structure

---
### Write Tests as you code

My typical workflow is to repeat:

```
# make edits
include("src/MyPackage.jl")
include("test/runtests.jl")
```