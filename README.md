<div align="center">

<img src="Banner.png" width="100%" height="auto" />

|  |     |
| -------------------- | --- |
| Stable Documentation | [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/stable/) |
| Dev Documentation    | [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/dev/)    |
| Tests                | [![CI](https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/actions/workflows/ci.yml)    |


</div>

This package provides some of the proposed Online Portfolio Selection (OPS) algorithms in the literature. The methods are implemented in a fully type-stable manner in Julia and can be used for research purposes. The package is still under development, and more methods will be added. Hopefully, novel methods will be added to the repo after completing the major benchmark methods.

## Installation
The latest stable version of the package can be installed by running the following command in the Julia REPL after pressing `]`:

```julia
pkg> add OnlinePortfolioSelection
```

The dev version of the package can be installed by running the following command in the Julia REPL after pressing `]`:
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
Contributions are warmly welcome. Please feel free to open an issue and discuss the changes you want to make. Afterward, fork the repo and make the changes. Then, open a pull request, and I will review and hopefully merge it.

## 🔮Motivation
Since my M.Sc. thesis is in the field of OPS, I thought it would be a worthwhile idea to implement some of the benchmark methods to use them to perform benchmarking experiments to compare the performance of my proposed method with the existing methods in the literature. Afterward, I thought it would be a good idea to share the repo with the community so that other researchers can use the methods for their research purposes and put time into developing novel strategies rather than implementing the existing ones. Hence, I decided to share the repo with the community, and hopefully, it will be helpful for other researchers.

## 📑License
This project is licensed under the MIT License - see the [LICENSE](https://github.com/shayandavoodii/OnlinePortfolioSelection.jl/blob/main/LICENSE) file for details.

## 📧Contact
If you have any questions or suggestions, please feel free to contact me via email: sh0davoodi@gmail.com  
Or feel free to open an issue in the repo.
