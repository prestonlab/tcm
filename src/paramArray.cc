#include <iostream>
#include "paramArray.h"

using namespace std;

ParamArray::ParamArray () {}

ParamArray::ParamArray (unsigned int n_sets) {
  params.resize(n_sets);
}

void ParamArray::setParam (Parameters param, unsigned int index) {
  params[index] = param;
}

void ParamArray::add (Parameters param) {
  params.push_back(param);
}

void ParamArray::addVector (unsigned int n_sets,
			    vector<double const *> param_mat) {
  unsigned int n_param = param_mat.size();
  vector<double> param_vec (n_param);
  Parameters param;

  for (unsigned int i = 0; i < n_sets; ++i) {
    for (size_t j = 0; j < n_param; ++j) {
      param_vec[j] = param_mat[j][i];
    }
    param = Parameters(param_vec);
    setParam(param, i);
  }
}

Parameters ParamArray::getParam (unsigned int index) {
  return params[index];
}

// void ParamArray::print () {
//   for (size_t i = 0; i < params.size(); ++i) {
//     cout << i << ":" << endl;
//     params[i].print();
//   }
// }
