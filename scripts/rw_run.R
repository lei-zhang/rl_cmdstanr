# =============================================================================
#### Info #### 
# =============================================================================
# simple Rescorla-Wagner model
#
# (C) Lei Zhang, 10-Aug-2020
# University of Vienna
# lei.zhang@univie.ac.at

rw_run = function(modelStr, test = TRUE, saveFit = FALSE, suffix=NULL,
                   nIter = 2000, nwarmup = NULL, nCore = NULL, seed = NULL,
                   adapt = 0.8, treedepth = 10) {
    # =============================================================================
    #### Construct Data #### 
    # =============================================================================
    # clear workspace
    library(cmdstanr); library(loo)
    L = list()
    
    load('data/example.RData')
    sz = dim(rw_example)
    nSubjects = sz[1]
    nTrials   = sz[2]
    
    dataList = list(nSubjects=nSubjects,
                     nTrials=nTrials, 
                     choice=rw_example[,,1], 
                     reward=rw_example[,,2])
    
    # model string in a separate .stan file
    modelFile = paste0("scripts/", modelStr,".stan")
    
    # compile to C++
    mod = cmdstan_model(modelFile)
    
    #### Stan specs
    if (test == TRUE) {
      nCores = getOption("mc.cores", 1)
      nIters = 2
      nChains  = 1 
      nWarmup  = 1 # warmup in stan to optimize internal sampling procedures
      nRefresh = 1
      est_seed = sample.int(.Machine$integer.max, 1)
      
    } else {
      if (is.null(nCore)) {
        nCores = getOption("mc.cores", 4)
      } else {
        nCores = getOption("mc.cores", nCore)
      }
      
      if (is.null(seed)) {
        est_seed = sample.int(.Machine$integer.max, 1) 
      } else {
        est_seed = seed  
      }
      
      nIters = nIter
      nRefresh = nIter / 10
      nChains  = 4
      if (is.null(nwarmup)) {
        nWarmup = floor(nIters/2)
      } else {
        nWarmup = nwarmup
      }
    }

    # =============================================================================
    #### Running Stan #### 
    # =============================================================================
    cat("Estimating", modelFile, "model... \n")
    startTime = Sys.time(); print(startTime)
    cat("Calling", nChains, "simulations in Stan... \n")
    
    fit = mod$sample(
                data = dataList,
                chains = nChains,
                parallel_chains = nCores,
                refresh = nRefresh,
                iter_warmup = nWarmup,
                iter_sampling = nIters - nWarmup,
                seed = est_seed,
                max_treedepth = treedepth,
                adapt_delta = adapt
                )
    
    cat("Finishing", modelFile, "model simulation ... \n")
    endTime = Sys.time(); print(endTime)  
    cat("It took",as.character.Date(endTime - startTime), "\n")
    
    L$data = dataList
    L$fit  = fit
    
    if (test == FALSE) { 
      # print model diagnostic 
      fit$cmdstan_diagnose()
    
      # record LOO for model comparison
      cat(' # --- LOO ---: \n')
      L_mat = fit$draws("log_lik")
      rel_n_eff = loo::relative_eff(exp(L_mat), chain_id = rep(1:nChains, each = nIters - nWarmup))
      loo = suppressWarnings(loo::loo(L_mat, r_eff = rel_n_eff))
      print(loo)
      
      L$loo  = loo
    }
      
    if (saveFit == TRUE) {
      saveRDS(L, file = paste0('stanfits/', modelStr, '_ppc', suffix, '.RData'))
    }
    
    return(L)
}
# end of function
