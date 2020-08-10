data {
  int<lower=1> nSubjects;
  int<lower=1> nTrials;
  int<lower=1,upper=2> choice[nSubjects, nTrials];     
  real<lower=-1, upper=1> reward[nSubjects, nTrials]; 
}

transformed data {
  vector[2] initV;  // initial values for V
  initV = rep_vector(0.0, 2);
}

parameters {
  // group-level parameters
  real alpha_mu_raw; 
  real tau_mu_raw;
  real<lower=0> alpha_sd_raw;
  real<lower=0> tau_sd_raw;
  
  // subject-level raw parameters
  vector[nSubjects] alpha_raw;
  vector[nSubjects] tau_raw;
}

transformed parameters {
  real<lower=0,upper=1> alpha_mu; 
  real<lower=0,upper=10> tau_mu;
  vector<lower=0,upper=1>[nSubjects] alpha;
  vector<lower=0,upper=10>[nSubjects] tau;
  
  alpha_mu  = Phi_approx(alpha_mu_raw);
  tau_mu = Phi_approx(tau_mu_raw);
  alpha  = Phi_approx(alpha_mu_raw  + alpha_sd_raw * alpha_raw);
  tau = Phi_approx(tau_mu_raw + tau_sd_raw * tau_raw) * 10;
}

model {
  // group-level priors
  alpha_mu_raw  ~ normal(0,1);
  tau_mu_raw ~ normal(0,1);
  alpha_sd_raw  ~ normal(0,0.3);
  tau_sd_raw ~ normal(0,0.3);
  
  // individual-level priors
  alpha_raw  ~ normal(0,1);
  tau_raw ~ normal(0,1);
  
  for (s in 1:nSubjects) {
    vector[2] v; 
    real pe;    
    v = initV;

    for (t in 1:nTrials) {        
      choice[s,t] ~ categorical_logit( tau[s] * v );
      
      pe = reward[s,t] - v[choice[s,t]]; // prediction error
      v[choice[s,t]] = v[choice[s,t]] + alpha[s] * pe; // value update
    }
  }    
}

generated quantities {
  real log_lik[nSubjects];
  int y_pred[nSubjects, nTrials];
  
  y_pred = rep_array(-999,nSubjects ,nTrials);
  
  { // local block
    for (s in 1:nSubjects) {
        vector[2] v; 
        real pe;    
        v = initV;
        log_lik[s] = 0;
        
        for (t in 1:nTrials) {
          log_lik[s] += categorical_logit_lpmf(choice[s,t] | tau[s] * v);
          y_pred[s,t] = categorical_logit_rng( tau[s] * v );
          pe = reward[s,t] - v[choice[s,t]];
          v[choice[s,t]] = v[choice[s,t]] + alpha[s] * pe; 
        }
    }    
  }  
}
