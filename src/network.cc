#include <iostream>
#include <iomanip>
#include <vector>
#include <cmath>
#include <algorithm>
#include "network.h"
#include "context.cc"
#include "weights.cc"

using namespace std;

Network::Network () {};

Network::Network (unsigned int n_items, Parameters model_param) {
  N = n_items + 2;
  NI = n_items;
  NO = 2;

  // indices
  II.resize(NI);
  IO.resize(NO);
  for (size_t i = 0; i < NI; ++i) {
    II[i] = i;
  }
  for (size_t i = 0; i < NO; ++i) {
    IO[i] = NI + i;
  }
  I_init = NI;
  I_ri = NI + 1;
  
  // parameters
  param = model_param;

  // initialize layers
  c = Context(N, param.Benc);
  cin_exp = Context(N);
  cin_pre = Context(N);
  f = Context(N);
  c_rec_init = Context(N);

  // recall competition
  a.resize(NI);
  p.resize(NI+1);

  // weights
  wfc_exp = Weights(N, 0, 0);
  wfc_pre = Weights(N, param.Afc, param.Dfc);
  wcf_exp = Weights(N, 0, 0);
  wcf_pre = Weights(N, param.Acf, param.Dcf);
  for (size_t i = 0; i < wcf_pre.connect.size(); ++i) {
    for (size_t j = 0; j < NO; ++j) {
      wcf_pre.connect[i][IO[j]] = 0;
    }
  }
  wcf_sem = Weights(N, 0, 0);

  // store initial states of c_study and wcf
  wfc_exp_init = wfc_exp;
  wfc_pre_init = wfc_pre;
  wcf_exp_init = wcf_exp;
  wcf_pre_init = wcf_pre;
}

void Network::setSem (vector<unsigned int> * poolno, vector< vector<double> > * poolsem) {
  if (param.Sfc != 0) {
    for (unsigned int i = 0; i < NI; ++i) {
      for (unsigned int j = 0; j < NI; ++j) {
	wfc_pre.connect[i][j] += (*poolsem)[(*poolno)[i]-1][(*poolno)[j]-1] * param.Sfc;
      }
    }
  }

  if (param.Scf != 0) {
    for (unsigned int i = 0; i < NI; ++i) {
      for (unsigned int j = 0; j < NI; ++j) {
	wcf_sem.connect[i][j] = (*poolsem)[(*poolno)[i]-1][(*poolno)[j]-1] * param.Scf;
      }
    }
  }
}

void Network::clear () {
  c.clear();
  cin_exp.clear();
  cin_pre.clear();
  f.clear();
  r_prev.clear();
  wfc_exp = wfc_exp_init;
  wfc_pre = wfc_pre_init;
  wcf_exp = wcf_exp_init;
  wcf_pre = wcf_pre_init;
}

void Network::storeContext (unsigned int unit) {
  wfc_exp.learnOrthog(unit, c);
  wcf_exp.L = param.Lcf;
  wcf_exp.learnOrthog(unit, c);
}

void Network::storeCue () {
  c_rec_init = c;
}

void Network::getCue () {
  c = c_rec_init;
}

void Network::presentDistract (unsigned int unit) {
  f.setUnit(unit);
  c.updateOrthog(&f);
}

void Network::presentItem (unsigned int unit) {
  f.setUnit(unit);
  wfc_pre.projectOrthog(unit, cin_pre);
  cin_pre.normalize();
  c.update(&cin_pre);
  storeContext(unit);
}

void Network::reactivateItem (unsigned int unit) {
  f.setUnit(unit);
  wfc_exp.projectOrthog(unit, cin_exp);
  wfc_pre.projectOrthog(unit, cin_pre);
  cin_exp.combine(&cin_pre, 1, 1);
  cin_exp.normalize();
  c.update(&cin_exp);
  r_prev.push_back(unit + 1);
}

void Network::reactivateStart () {
  cin_exp.setUnit(I_init);
  c.update(&cin_exp);
}

void Network::resetRecall () {
  f.setUnit(NI - 1);
  getCue();
  r_prev.clear();
}

void Network::setB (double Bnew) {
  c.setB(Bnew);
}

void Network::setLcf (double L) {
  param.Lcf = L;
}

void Network::cueItem () {
  double * context = c.getStatePtr();
  for (unsigned int i = 0; i < NI; ++i) {
    a[i] = 0;
    for (unsigned int j = 0; j < N; ++j) {
      a[i] += context[j] * (wcf_exp.connect[i][j] + wcf_pre.connect[i][j]);
    }
    a[i] = pow(max(a[i], param.amin), param.T);
  }
}

void Network::cueItemSem () {
  double * context = c.getStatePtr();
  for (unsigned int i = 0; i < NI; ++i) {
    a[i] = 0;

    // item units
    for (unsigned int j = 0; j < NI; ++j) {
      a[i] += context[j] * (wcf_exp.connect[i][j] + wcf_pre.connect[i][j] + wcf_sem.connect[i][j]);
    }

    // other units
    for (unsigned int j = 0; j < NO; ++j) {
      a[i] += context[IO[j]] * wcf_exp.connect[i][IO[j]];
    }

    // transformed activation
    a[i] = pow(max(a[i], param.amin), param.T);
  }
}

void Network::cueItemSemSplit (double I) {
  double * context = c.getStatePtr();
  double * item = f.getStatePtr();
  for (unsigned int i = 0; i < NI; ++i) {
    a[i] = 0;

    // item units
    for (unsigned int j = 0; j < NI; ++j) {
      a[i] += context[j] * (wcf_exp.connect[i][j] + wcf_pre.connect[i][j]);
      a[i] += (context[j] * (1 - I) + item[j] * I) * wcf_sem.connect[i][j];
    }

    // other units
    for (unsigned int j = 0; j < NO; ++j) {
      a[i] += context[IO[j]] * wcf_exp.connect[i][IO[j]];
    }

    // transformed activation
    a[i] = pow(max(a[i], param.amin), param.T);
  }
}

void Network::removeRepeats () {
  for (size_t i = 0; i < r_prev.size(); ++i) {
    a[r_prev[i] - 1] = 0;
  }
}

void Network::pstop (double output_pos) {
  if (output_pos == NI) {
    // all items have been recalled; must stop
    p[p.size()-1] = 1;
  } else {
    if (param.stop == 1) {
      p[p.size()-1] = param.X1 * exp(param.X2 * output_pos);
    } else if (param.stop == 2) {
      double tot_rec = 0;
      double tot_not_rec = 0;

      // activation of previously recalled items
      for (size_t i = 0; i < r_prev.size(); ++i) {
	tot_rec += a[r_prev[i] - 1];
      }

      // activation of items not recalled yet
      for (size_t i = 0; i < a.size(); ++i) {
	tot_not_rec += a[i];
      }
      tot_not_rec -= tot_rec;

      p[p.size()-1] = param.X1 + exp(-param.X2 * (tot_not_rec / tot_rec));
    } else {
      throw runtime_error("Unknown stop rule code.");
    }

    // keep probabilities from hitting floor or ceiling, to prevent
    // any recall event from being labeled impossible
    p[p.size()-1] = max(min(p[p.size()-1], 1 - param.pmin), param.pmin);
  }
}

void Network::recallComp () {
  
  if (p[p.size()-1] == 1) {
    // if P(stop) = 1, all item recall probabilities are 0
    for (size_t i = 0; i < a.size(); ++i) {
      p[i] = 0;
    }
  } else {
    double atot = 0;
    for (size_t i = 0; i < a.size(); ++i) {
      atot += a[i];
    }
    
    if (atot == 0) {
      // all support is 0, but P(stop) is not 1; must set to uniform
      // support to get a valid probability distribution
      double asize = static_cast<double>(NI);
      for (size_t i = 0; i < a.size(); ++i) {
	p[i] = (1 - p[p.size()-1]) / asize;
      }
    } else {
      // calculate the overall probability for each item; including
      // P(stop), p should sum to 1
      for (size_t i = 0; i < a.size(); ++i) {
	p[i] = (1 - p[p.size()-1]) * (a[i] / atot);
      }
    }
  }
}

vector<double> Network::getProb () {
  return p;
}

void Network::printState () {
  cout << "f:" << endl;
  f.print();
  cout << "c:" << endl;
  c.print();
  cout << "a:" << endl;
  for (size_t i = 0; i < a.size(); ++i) {
    cout << fixed << setprecision(4) << a[i] << ' ';
  }
  cout << endl;

  cout << "p:" << endl;
  for (size_t i = 0; i < p.size(); ++i) {
    cout << fixed << setprecision(4) << p[i] << ' ';
  }
  cout << endl;
  cout << endl;
}

void Network::printContext () {
  c.print();
}

void Network::printContextIn () {
  cin_exp.print();
}
