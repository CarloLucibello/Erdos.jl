To build and inspect the documentation
```
cd docs/
julia make.jl
mkdocs build
mkdocs serve
```

Documenter.jl's autodeploy is not working for some reason. After building the docs
deploy manually with
```
mkdocs gh-deploy
```
