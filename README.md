<div align="center">

<img src="Banner.png" width="100%" height="auto" />

|  |     |
| -------------------- | --- |
| Stable Documentation | [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/stable/) |
| Dev Documentation    | [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/dev/)    |
| Tests                | [![CI](https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/actions/workflows/ci.yml)    |
| Coverage | [![codecov](https://codecov.io/gh/shayandavoodii/OnlinePortfolioSelection.jl/branch/main/graph/badge.svg?token=BSZJR7AL1O)](https://codecov.io/gh/shayandavoodii/OnlinePortfolioSelection.jl) |


</div>
<div align="justify">
This package provides some of the proposed Online Portfolio Selection (OPS) algorithms in the literature. The methods are implemented in a fully type-stable manner in Julia and can be used for research purposes. The package is still under development, and more methods will be added. Hopefully, novel methods will be added to the repo after completing the major benchmark methods. Currently, the package provides the following algorithms:
</div>
<div align="center">

| Algorithm | Strategy          | Stable | Dev |
| --------- | ----------------- |:------:|:---:|
| [CORN-U]()    | Pattern-Matching  | ✔      |     |
| [CORN-K](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/stable/PM/#Correlation-driven-Nonparametric-Learning)    | Pattern-Matching  | ✔      |     |
| [DRICORN-K](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/stable/PM/#Dynamic-RIsk-CORrelation-driven-Non-parametric) | Pattern-Matching  | ✔      |     |
| [CRP](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/stable/benchmark/#Run-CRP)       | Benchmark         | ✔      |     |
| [UP](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/stable/FW/#Run-UP)        | Follow the Winner | ✔      |     |
| [EG](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/stable/FW/#Exponential-Gradient)        | Follow the Winner | ✔      |     |
| RPRT      | Follow the loser  |        | ✔   |
| BS        | Follow the winner | ✔     |     |

</div>

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

## 📝To-do list
- [ ] Implement BCRP
- [x] ~~Implement CORN~~
- [x] ~~Implement DRICORN~~
- [ ] Implement BS
- [ ] Implement Anticor
- [ ] Implement $B^k$
- [ ] Implement $B^{NN}$
- etc.

## 👨‍💻Contributing

<div align="justify">
Contributions are warmly welcome. Please feel free to open an issue and discuss the changes you want to make. Afterward, fork the repo and make the changes. Then, open a pull request, and I will review and hopefully merge it.
</div>

## 🔮Motivation
<div align="justify">
Since my M.Sc. thesis is in the field of OPS, I thought it would be a worthwhile idea to implement some of the benchmark methods to use them to perform benchmarking experiments to compare the performance of my proposed method with the existing methods in the literature. Afterward, I thought it would be a good idea to share the repo with the community so that other researchers can use the methods for their research purposes and put time into developing novel strategies rather than implementing the existing ones. Hence, I decided to share the repo with the community, and hopefully, it will be helpful for other researchers.
</div>

## 📑License
This project is licensed under the MIT License - see the [LICENSE](https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/main/LICENSE) file for details.

## 📧Contact
If you have any questions or suggestions, please feel free to contact me via email: sh0davoodi@gmail.com  
Or feel free to open an issue in the repo.
