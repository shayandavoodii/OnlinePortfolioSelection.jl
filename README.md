<div align="center">

<img src="Banner.png" width="100%" height="auto" />

<table>
    <!-- Docs -->
    <tr>
        <td>Documentation (Latest)</td>
        <td>
            <a href="https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/dev/"><img src="https://img.shields.io/badge/docs-dev-blue.svg"/></a>
        </td>
    </tr>
    <!-- Tests -->
    <tr>
        <td>Continuous Integration</td>
        <td>
            <a href="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/actions/workflows/ci.yml"><img src="https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/actions/workflows/ci.yml/badge.svg"/></a>
        </td>
    </tr>
    <!-- Coverage -->
    <tr>
        <td>Coverage</td>
        <td>
            <a href="https://codecov.io/gh/shayandavoodii/OnlinePortfolioSelection.jl"><img src="https://codecov.io/gh/shayandavoodii/OnlinePortfolioSelection.jl/branch/main/graph/badge.svg?token=BSZJR7AL1O"/></a>
        </td>
    </tr>
    <!-- DOI -->
    <tr>
        <td>DOI</td>
        <td>
            <a href="https://zenodo.org/badge/latestdoi/604664429"><img src="https://zenodo.org/badge/604664429.svg"/></a>
        </td>
    </tr>
</table>

</div>

<div id="top"></div>

<!-- TABLE OF CONTENTS -->
<ol>
  <li><a href="#about">About</a></li>
  <li><a href="#installation">Installation</a></li>
  <li><a href="#to-do-list">TODO LIST</a></li>
  <li><a href="#contributing">Contributing</a></li>
  <li><a href="#motivation">Motivation</a></li>
  <li><a href="#license">License</a></li>
  <li><a href="#contact">Contact</a></li>
</ol>

<!-- About -->
## About

<div align="justify">
This package provides some of the proposed Online Portfolio Selection (OPS) algorithms in the literature. The methods are implemented in a fully type-stable manner in Julia and can be used for research purposes. The package is still under development, and more methods will be added. Hopefully, novel methods will be added to the repo after completing the major benchmark methods. Currently, the package provides the following algorithms:
</div>
<div align="center">

| Row № | Algorithm | Strategy          | Stable | Dev |
|:---:| --------- | ----------------- |:------:|:---:|
| 1 | [CORN-U]()    | Pattern-Matching  | ✔      |     |
| 2 | [CORN-K](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/stable/PM/#Correlation-driven-Nonparametric-Learning)    | Pattern-Matching  | ✔      |     |
| 3 | [DRICORN-K](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/stable/PM/#Dynamic-RIsk-CORrelation-driven-Non-parametric) | Pattern-Matching  | ✔      |     |
| 4 | [CRP](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/stable/benchmark/#Run-CRP)       | Benchmark (Market) | ✔      |     |
| 5 | [UP](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/stable/FW/#Run-UP)        | Follow the Winner | ✔      |     |
| 6 | [EG](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/stable/FW/#Exponential-Gradient)        | Follow the Winner | ✔      |     |
| 7 | RPRT      | Follow the Loser  | ✔       |    |
| 8 | [BS](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/stable/benchmark/#BS)        | Benchmark (Market) | ✔     |     |
| 9 | Anticorn  | Follow the Loser  | ✔       |    |

</div>

<p align="right">🆙<a href="#top">Table of cotents</a></p>

<!-- Installation -->
## Installation

<div align="justify">

The latest stable version of the package can be installed by running the following command in the Julia REPL after pressing `]`:

</div>

```julia
pkg> add OnlinePortfolioSelection
```

or

```julia
julia> using Pkg; Pkg.add("OnlinePortfolioSelection")
```

Also, the dev version of the package can be installed by running the following command in the Julia REPL after pressing `]`:

```julia
pkg> add https://github.com/shayandavoodii/OnlinePortfolioSelection.jl.git
```

<p align="right">🆙<a href="#top">Table of cotents</a></p>

<!-- TODO LIST -->
## To-do list
- [ ] Implement BCRP
- [x] ~~Implement CORN~~
- [x] ~~Implement DRICORN~~
- [x] ~~Implement BS~~
- [x] ~~Implement Anticor~~
- [ ] Implement $B^k$
- [ ] Implement $B^{NN}$
- etc.

<p align="right">🆙<a href="#top">Table of cotents</a></p>

<!-- Contributing -->
## Contributing

<div align="justify">
Contributions are warmly welcome. Please feel free to open an issue and discuss the changes you want to make. Afterward, fork the repo and make the changes. Then, open a pull request, and I will review and hopefully merge it.
</div>

<p align="right">🆙<a href="#top">Table of cotents</a></p>

<!-- Motivation -->
## Motivation
<div align="justify">
Since my M.Sc. thesis is in the field of OPS, I thought it would be a worthwhile idea to implement some of the benchmark methods to use them to perform benchmarking experiments to compare the performance of my proposed method with the existing methods in the literature. Afterward, I thought it would be a good idea to bundle the repo as an open-source package, and share it with the community so that other researchers can use the methods for their research purposes and put time into developing novel strategies rather than implementing the existing ones. Furthermore, because of my personal interest in the OPS field, I will continue to develop the package and add more algorithms to it. I hope this package will be useful for the community and will be used by other researchers in the field.
</div>

<p align="right">🆙<a href="#top">Table of cotents</a></p>

<!-- License -->
## License
This project is licensed under the MIT License - see the [LICENSE](https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/main/LICENSE) file for details.

<p align="right">🆙<a href="#top">Table of cotents</a></p>

<!-- Contact -->
## Contact
If you have any questions or suggestions, please feel free to contact me via email: sh0davoodi@gmail.com  
Or feel free to open an issue in the repo.

<p align="right">🆙<a href="#top">Table of cotents</a></p>