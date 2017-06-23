To build and inspect the documentation
```
cd Erdos.jl/
julia docs/make.jl
cd docs
mkdocs build
mkdocs serve
```

Documenter.jl's autodeploy is not working for some reason. After building the docs
deploy manually with
```
mkdocs gh-deploy
```
