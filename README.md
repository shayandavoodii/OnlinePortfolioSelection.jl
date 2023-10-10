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
  <li><a href="#disclaimer">Disclaimer</a></li>
  <li><a href="#quick-start">Quick Start</a></li>
  <ul>
    <li><a href="#installation">Installation</a></li>
    <li><a href="#example">Example</a></li>
  </ul>
  <li><a href="#to-do-list">TODO LIST</a></li>
  <li><a href="#contribution">Contribution</a></li>
  <li><a href="#motivation">Motivation</a></li>
  <li><a href="#citation">Citation</a></li>
  <li><a href="#license">License</a></li>
  <li><a href="#contact">Contact</a></li>
</ol>

<!-- About -->
## About

<div align="justify">
This package provides some of the proposed Online Portfolio Selection (OPS) algorithms in the literature. The methods are implemented in a fully type-stable manner in Julia and can be used for research purposes. The package is still under development, and more methods will be added. Hopefully, novel methods will be added to the repo after completing the major benchmark methods. Currently, the package provides the following algorithms:
</div>
<div align="center">

| Row № | Algorithm                                                                                                                                                          | Strategy           | Row № | Algorithm                                                                                                                                                          | Strategy           |
|:-----:|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------: |:------------------ |:-----:|:------------------------------------------------------------------------------------------------------------------------------------------------------------------ |:------------------ |
| 1     | [CORN-U](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/dev/PM/#Correlation-driven-Nonparametric-Learning)                                           | Pattern-Matching   | 8     | [BS](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/dev/benchmark/#BS)                                                                               | Benchmark (Market) |
| 2     | [CORN-K](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/dev/PM/#Correlation-driven-Nonparametric-Learning)                                           | Pattern-Matching   | 9     | [Anticor](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/dev/FL/#Anti-Correlation-(Anticor))                                                         | Follow the Loser   |
| 3     | [DRICORN-K](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/dev/PM/#Dynamic-RIsk-CORrelation-driven-Non-parametric)                                   | Pattern-Matching   | 10    | [OLMAR](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/dev/FL/#Online-Moving-Average-Reversion-(OLMAR))                                              | Follow the Loser   |
| 4     | [CRP](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/dev/benchmark/#CRP)                                                                             | Benchmark (Market) | 11    | [Bᴷ](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/dev/PM/#Bᴷ)                                                                                      | Pattern-Matching   |
| 5     | [UP](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/dev/FW/#Universal-Portfolio)                                                                     | Follow the Winner  | 12    | [LOAD](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/dev/Combined/#LOcal-ADaptive-learning-system-(LOAD))                                           | Combination of Strategies |
| 6     | [EG](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/dev/FW/#Exponential-Gradient)                                                                    | Follow the Winner  | 13    | [MRvol](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/dev/Combined/#MRvol)                                                                          | Combination of Strategies |
| 7     | [RPRT](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/dev/FL/#Reweighted-Price-Relative-Tracking-System-for-Automatic-Portfolio-Optimization-(RPRT)) | Follow the Loser   | 14    | [CW-OGD](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/dev/ML/#Combination-Weights-based-on-Online-Gradient-Descent-(CW-OGD))                                                                         | Combination of Strategies |

</div>

<p align="right">🆙<a href="#top">Table of cotents</a></p>

<!-- Disclaimer -->
## Disclaimer

<div align="justify">

This package is developed for **research purposes** and **is not intended to be used for investment purposes**. The author(s) is(are) not responsible for any loss of money or any other financial damages caused by using this package.

</div>
<p align="right">🆙<a href="#top">Table of cotents</a></p>

---
<!-- Quick Start -->
## Quick Start

<!-- Installation -->
### Installation

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

<!-- Example -->
### Example
All the available strategies can be found by running the following command after importing the package:

```julia
julia> using OnlinePortfolioSelection

julia> opsmethods()
```

In summary, all the implemented algorithms' names appear with lowercase letters. All of the strategies, return an object of type `OPSAlgorithm` in which the following fields are incorporated:

```julia
julia> fieldnames(OPSAlgorithm)
(:n_assets, :b, :alg)
```

where `n_assets` conveys the number of assets, `b` contains the corresponding weights of each asset in each investment period, and `alg` repersents the name of the algorithm which resulted the output. In order to get more information about a specific strategy, you can type `?` in the REPL and then call the name of the strategy. For example, to get more information about the `CORN-K` strategy, you can run the following command:

```julia
help?> cornk
```

Finally, to run the `CORN-K` strategy, you can run the following commands

```julia
juila> using OnlinePortfolioSelection

# Generate a random price matrix. The rows are the assets, and the columns represent the time.
julia> adj_close_random = rand(10, 100);

# Set the parameters of the strategy
julia> hor = 10; # The investment horizon
julia> nexp = 5; # The number of experts
julia> ml_tw = 3; # The maximum length of the time windows to be examined
julia> ml_cor = 5; # The maximum number of correlation coefficients to be examined

# Run the algorithm
julia> m_cornk = cornk(adj_close_random, hor, nexp, ml_tw, ml_cor)
******************************************************************************
This program contains Ipopt, a library for large-scale nonlinear optimization.
 Ipopt is released as open source code under the Eclipse Public License (EPL).
         For more information visit https://github.com/coin-or/Ipopt
******************************************************************************

# Get weights
julia> m_cornk.b
10×10 Matrix{Float64}:
 0.088856    0.147974     …  0.00084875  0.223069
 0.0         0.0             0.00347507  0.0
 0.101514    0.000792416     0.00100889  0.0553558
 0.00913491  0.0805729       0.00100889  0.10233
 0.683795    0.0             0.31303     0.0
 0.00913491  0.0          …  0.0         0.0407096
 0.0350864   0.0208009       0.251554    0.239765
 0.0         0.219552        0.395477    0.0
 0.0232303   0.349871        0.0131345   0.163805
 0.0492489   0.180437        0.0204634   0.174965
```

Further information about the implemented strategies and the API can be found in the [documentation](https://shayandavoodii.github.io/OnlinePortfolioSelection.jl/dev/).

<p align="right">🆙<a href="#top">Table of cotents</a></p>

---

<!-- TODO LIST -->
## To-do list
- [ ] Implement BCRP
- [x] ~~Implement CORN~~
- [x] ~~Implement DRICORN~~
- [x] ~~Implement BS~~
- [x] ~~Implement Anticor~~
- [x] ~~Implement $B^k$~~
- [ ] Implement $B^{NN}$
- etc.

<p align="right">🆙<a href="#top">Table of cotents</a></p>

<!-- Contribution -->
## Contribution

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

<!-- Citation -->
## Citation

<div align="justify">
If you use the package in your research, please cite the package using the following BibTeX entry:
</div>

```bibtex
@software{shayan_davoodi_2023_7955234,
  author       = {Shayan Davoodi},
  title        = {shayandavoodii/OnlinePortfolioSelection.jl: v1.5.0},
  month        = may,
  year         = 2023,
  publisher    = {Zenodo},
  version      = {v1.5.0},
  doi          = {10.5281/zenodo.7955234},
  url          = {https://doi.org/10.5281/zenodo.7955234}
}
```

<div align="justify">
Other citation styles can be found <a href="https://doi.org/10.5281/zenodo.7905042">here</a> at the bottom of the page (Export section).
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
