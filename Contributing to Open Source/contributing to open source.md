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
- Fork the package on GitHub

- On your machine, add a remote

`git remote add rname https://github.com/joshday/Repo.git`

- Make and commit your updates

`git commit -am "commit all my changes"`

- Push changes to your remote

`git push rname`

- Make PR (pull request) from GitHub
