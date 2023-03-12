<div align="center">

# OPS.jl
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://shayandavoodii.github.io/OPS.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://shayandavoodii.github.io/OPS.jl/dev/)
[![Build Status](https://travis-ci.com/shayandavoodii/OPS.jl.svg?branch=master)](https://travis-ci.com/shayandavoodii/OPS.jl)
[![Coverage](https://codecov.io/gh/shayandavoodii/OPS.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/shayandavoodii/OPS.jl)
[![Coverage](https://coveralls.io/repos/github/shayandavoodii/OPS.jl/badge.svg?branch=master)](https://coveralls.io/github/shayandavoodii/OPS.jl?branch=master)
</div>

This repo contains some benchmark methods for Online Portfolio Selection (OPS). The methods are implemented in Julia and can be used for research purposes. The repo is still under development, and more methods will be added. Hopefully, novel methods will be added to the repo after completing the major benchmark methods.

## 🔮Motivation
Since my MSc thesis is in the field of OPS, I thought it would be a worthwhile idea to implement some of the benchmark methods to use them to perform benchmarking experiments to compare the performance of my proposed method with the existing methods in the literature. Afterward, I thought it would be a good idea to share the repo with the community so that other researchers can use the methods for their research purposes and put time into developing novel strategies rather than implementing the existing ones. Hence, I decided to share the repo with the community, and hopefully, it will be helpful for other researchers.

## Installation
The dev version of the package can be installed by running the following command in the Julia REPL after pressing `]`:
```julia
pkg> add https://github.com/shayandavoodii/OPS.jl.git
```

## Usage
The package can be imported by running the following command in the Julia REPL:
```julia
julia> using OPS
```

## 📚Documentation
The documentation of the package will be available soon. In the meantime, you can check the docstrings of the functions by running the following command in the Julia REPL:
```julia
julia> ?function_name
```

## 📝To-do list
- [ ] Implement BCRP
- [ ] Implement CORN
- [ ] Implement DRICORN
- [ ] Implement BS
- [ ] Implement Anticor
- [ ] Implement $B^k$
- [ ] Implement $B^NN$
- etc.

## 👨‍💻Contributing
Contributions are warmly welcome. Please feel free to open an issue and discuss the changes you want to make. Afterward, fork the repo and make the changes. Then, open a pull request, and I will review and hopefully merge it.

## 📑License
This project is licensed under the MIT License - see the [LICENSE](https://github.com/shayandavoodii/OPS.jl/blob/main/LICENSE) file for details.

## 📧Contact
If you have any questions or suggestions, please feel free to contact me via email: sh0davoodi@gmail.com  
Or feel free to open an issue in the repo.
