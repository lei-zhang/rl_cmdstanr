## Short tutorial on {cmdstanr} for the simple Rescorla-Wagner RL model

v1 - Lei Zhang - 10 Aug 2020

## tl;dr
```
f = rw_run('rw_hba', saveFit = T, test = F)
```

## longer explanation
This repository contains:
```
root
  ├─ data       # example data for a simple 2-armed bandit task
  ├─ scripts    # stan model and R function
  ├─ stanfits   # to save fitted objects
```

[{CmdStanR}](https://mc-stan.org/cmdstanr/articles/cmdstanr.html) is a lightweight interface to [Stan](https://mc-stan.org/) for R users that provides an alternative to the traditional [{RStan}](https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started) interface. It employs the most updated functionalities in [cmdstan](https://mc-stan.org/users/interfaces/cmdstan.html) and provides nicer tools to operate the posterior. 

For researchers using computational modeling to understand cognition, if you have used [{RStan}](https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started) and now consider switching to [{CmdStanR}](https://mc-stan.org/cmdstanr/articles/cmdstanr.html), here is a short tutorial for you. In essence, all your &ast.stan models stay intact, and all you need to change is the wrapper function where you call stan models. 

As an example, here I have a simple *Rescorla-Wagner model* for a 2-armed bandit task, with the hierarchical Bayesian approach [(Ahn et al., 2017)](https://github.com/CCS-Lab/hBayesDM). The model is called [rw_hba.stan](scripts/rw_hba.stan). Plus, the wrapper function is called [rw_run.R](scripts/rw_run.R), and the main input argument is the model string. All commends in this wrapper function have been updated to be compatible with the [{CmdStanR}](https://mc-stan.org/cmdstanr/articles/cmdstanr.html) package. 

To run the model, simply call: 
```
f = rw_run('rw_hba', saveFit = T, test = F)
```

In addition, I let the function print out stan diagnostic messages; also, I include the computation of LOO for model comparison.

Note: when `test = T`, the wrapper function will only run 1 chain with 2 samples. This test mode is idea for debug stan models. 

___

For bug reports, please contact Lei Zhang ([lei.zhang@univie.ac.at](mailto:lei.zhang@univie.ac.at)).

Thanks to [Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) and [shields.io](https://shields.io/).

___

### LICENSE

This license (CC BY-NC 4.0) gives you the right to re-use and adapt, as long as you note any changes you made, and provide a link to the original source. Read [here](https://creativecommons.org/licenses/by-nc/4.0/) for more details. 

![](https://upload.wikimedia.org/wikipedia/commons/9/99/Cc-by-nc_icon.svg)