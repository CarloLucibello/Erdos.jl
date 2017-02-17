To build and inspect the documentation
```
cd docs/
julia make.jl
mkdocs build
mkdocs serve
```

Documenter.jl's autodeploy is not working for some reason.

To update the documentation manually:
```
git checkout master
cd docs/
julia make.jl
mkdocs build
checkout gh-pages
/bin/cp -rf site/* ../
git push origin gh-pages
```


