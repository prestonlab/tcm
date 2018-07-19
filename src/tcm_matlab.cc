#include <iostream>
#include <cmath>
#include <vector>

#include "mex.h"
#include "parameters.h"
#include "paramArray.h"
#include "recall.h"

using namespace std;

double run_tcm (double *r_mat, double *param_mat, unsigned int R, 
		unsigned int P, unsigned int N) {
  vector<double> param_vec (P);
  vector<unsigned int> recalls (R);
  double logl = 0;
  bool isdc = false;

  // read parameters into a Parameters object
  unsigned int i;
  for (i = 0; i < P; ++i) {
    param_vec[i] = param_mat[i];
  }
  Parameters param (param_vec);

  // copy recall codes into a vector
  for (i = 0; i < R; ++i) {
    recalls[i] = r_mat[i];
  }

  // initialize a Recall object
  Recall rec (N, N, isdc, param, recalls);

  // evaluate free recall likelihood
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
  bool isdc = false;

  // read parameters into a Parameters object
  unsigned int i;
  for (i = 0; i < P; ++i) {
    param_vec[i] = param_mat[i];
  }
  Parameters param (param_vec);

  // copy recall codes into a vector
  for (i = 0; i < R; ++i) {
    recalls[i] = r_mat[i];
  }
  
  // copy item numbers to a vector of vectors
  unsigned int j;
  unsigned int n = 0;
  for (j = 0; j < N; ++j) {
    for (i = 0; i < L; ++i) {
      pres_itemno[i][j] = static_cast<unsigned int>(itemno_mat[n]);
      n++;
    }
  }

  // copy semantic similarities to a vector of vectors
  n = 0;
  for (i = 0; i < M; ++i) {
    for (j = 0; j < M; ++j) {
      sem[i][j] = sem_mat[n];
      n++;
    }
  }

  // create recalls object for the task
  Recall rec (N, N, isdc, param, recalls);

  // attached semantic similarity values to the network
  rec.setPoolSim(&pres_itemno, &sem);

  // evaluate free recall likelihood
  rec.task();
  logl = rec.logL();
  
  return logl;
}

double run_tcm_distcon (double *r_mat, double *param_mat, unsigned int R, 
			unsigned int P, unsigned int N,
			double *itemno_mat, double *sem_mat,
			unsigned int n_list, unsigned int sem_rows,
			unsigned int sem_cols) {
  vector<double> param_vec (P);
  vector<unsigned int> recalls (R);
  vector< vector<unsigned int> > pres_itemno (n_list, vector<unsigned int> (N));
  vector< vector<double> > semvec (sem_rows, vector<double> (sem_cols));
  double logl = 0;
  bool isdc = true;

  // read parameters into a Parameters object
  unsigned int i;
  for (i = 0; i < P; ++i) {
    param_vec[i] = param_mat[i];
  }
  Parameters param (param_vec);

  // copy recall codes into a vector
  for (i = 0; i < R; ++i) {
    recalls[i] = r_mat[i];
  }
  
  // copy item numbers to a vector of vectors
  unsigned int j;
  unsigned int n = 0;
  unsigned int max_itemno = 0;
  for (j = 0; j < N; ++j) {
    for (i = 0; i < n_list; ++i) {
      pres_itemno[i][j] = static_cast<unsigned int>(itemno_mat[n]);
      max_itemno = max(max_itemno, pres_itemno[i][j]);
      n++;
    }
  }
  if (max_itemno > sem_cols) {
    mexErrMsgIdAndTxt("MATLAB:run_tcm_distcon:itemnoVecMismatch",
		      "Some items do not have corresponding vectors.");
  }

  // copy semantic similarities to a vector of vectors
  n = 0;
  for (j = 0; j < sem_cols; ++j) {
    for (i = 0; i < sem_rows; ++i) {
      semvec[i][j] = sem_mat[n];
      n++;
    }
  }

  // create recalls object for the task
  Recall rec (N, sem_rows, isdc, param, recalls);

  // attached semantic similarity values to the network
  rec.setPoolVec(&pres_itemno, &semvec);

  // evaluate free recall likelihood
  rec.task();
  logl = rec.logL();
  
  return logl;
}

/* The gateway function */
void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  double * r_mat; // recalls vector
  double * param_mat; // parameter vector/matrix
  size_t R; // number of recalls
  unsigned int P; // number of parameters
  unsigned int N; // list length
  double logl; // output scalar with log likelihood

  // read list length, recall events, and parameters
  N = mxGetScalar(prhs[0]);
  r_mat = mxGetPr(prhs[1]);
  R = mxGetN(prhs[1]);
  param_mat = mxGetPr(prhs[2]);
  P = mxGetN(prhs[2]);
  
  if (nrhs == 3) {
    logl = run_tcm(r_mat, param_mat, R, P, N);
  } else {
    unsigned int sem_type;
    unsigned int n_list;
    unsigned int sem_rows;
    unsigned int sem_cols;
    double * itemno_mat = mxGetPr(prhs[4]);
    double * sem_mat = mxGetPr(prhs[5]);
    
    sem_type = mxGetScalar(prhs[3]);
    n_list = mxGetM(prhs[4]);
    sem_rows = mxGetM(prhs[5]);
    sem_cols = mxGetN(prhs[5]);
    if (sem_type == 1) {
      // use semantic similarity to affect cuing in the model
      logl = run_tcm_sem(r_mat, param_mat, R, P, N, itemno_mat, sem_mat,
     			 n_list, sem_rows);
    } else {
      // use semantic feature vectors to drive context evolution
      logl = run_tcm_distcon(r_mat, param_mat, R, P, N, itemno_mat, sem_mat,
			     n_list, sem_rows, sem_cols);
    }
  }
  plhs[0] = mxCreateDoubleScalar(logl);
}
