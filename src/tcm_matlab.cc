#include <iostream>
#include "mex.h"
#include "parameters.cc"
#include "paramArray.cc"
#include "recall.cc"

double run_tcm (double *r_mat, double *param_mat, unsigned int R, 
		unsigned int P, unsigned int N) {
  vector<double> param_vec (P);
  vector<unsigned int> recalls (R);
  double logl = 0;

  unsigned int i;
  for (i = 0; i < P; ++i) {
    param_vec[i] = param_mat[i];
  }
  Parameters param (param_vec);

  for (i = 0; i < R; ++i) {
    recalls[i] = r_mat[i];
  }
  Recall rec (N, param, recalls);
  rec.taskSameList();
  logl = rec.logL();

  return logl;
}

double run_tcm_sem (double *r_mat, double *param_mat, unsigned int R, 
		    unsigned int P, unsigned int N,
		    double *itemno_mat, double *sem_mat,
		    unsigned int L, unsigned int M) {
  vector<double> param_vec (P);
  vector<unsigned int> recalls (R);
  vector< vector<unsigned int> > pres_itemno (L, vector<unsigned int> (N));
  vector< vector<double> > sem (M, vector<double> (M));
  double logl = 0;

  unsigned int i;
  for (i = 0; i < P; ++i) {
    param_vec[i] = param_mat[i];
  }
  Parameters param (param_vec);

  for (i = 0; i < R; ++i) {
    recalls[i] = r_mat[i];
  }
  
  // read in item numbers
  unsigned int j;
  unsigned int n = 0;
  for (j = 0; j < N; ++j) {
    for (i = 0; i < L; ++i) {
      pres_itemno[i][j] = static_cast<unsigned int>(itemno_mat[n]);
      n++;
    }
  }

  // read in semantic similarities
  n = 0;
  for (i = 0; i < M; ++i) {
    for (j = 0; j < M; ++j) {
      sem[i][j] = sem_mat[n];
      n++;
    }
  }

  Recall rec (N, param, recalls);
  rec.setPoolSim(&pres_itemno, &sem);
  //rec.taskSameList();
  rec.task();
  logl = rec.logL();
  
  return logl;
}

/* The gateway function */
void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  double * r_mat;
  double * param_mat;
  size_t R;
  unsigned int P;
  unsigned int N;
  unsigned int L;
  unsigned int M;
  double logl;

  N = (unsigned int)mxGetScalar(prhs[0]);

  r_mat = mxGetPr(prhs[1]);
  R = mxGetN(prhs[1]);
  param_mat = mxGetPr(prhs[2]);
  P = mxGetN(prhs[2]);

  if (nrhs == 3) {
    logl = run_tcm(r_mat, param_mat, R, P, N);
  } else {
    double * itemno_mat = mxGetPr(prhs[3]);
    L = mxGetM(prhs[3]);
    double * sem_mat = mxGetPr(prhs[4]);
    M = mxGetM(prhs[4]);
    
    logl = run_tcm_sem(r_mat, param_mat, R, P, N, itemno_mat, sem_mat,
		       L, M);
  }
  plhs[0] = mxCreateDoubleScalar(logl);
}
