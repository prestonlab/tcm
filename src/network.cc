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

Network::Network (unsigned int n_items, unsigned int n_units, bool isdc, Parameters model_param) {
  
  // parameters
  param = model_param;

  // indices for item units
  n_f_item = n_items;
  n_c_item = n_units;
  n_f = 0;
  n_c = 0;
  
  f_item.resize(n_items, 0);
  for (size_t i = 0; i < f_item.size(); ++i) {
    f_item[i] = i;
  }
  n_f += n_items;

  c_item.resize(n_units, 0);
  for (size_t i = 0; i < c_item.size(); ++i) {
    c_item[i] = i;
  }
  n_c += n_units;

  // interpresentation interval distraction
  if (param.Bipi > 0) {
    f_ipi.resize(n_items, 0);
    for (size_t i = 0; i < f_ipi.size(); ++i) {
      f_item[i] = n_f + i;
    }
    n_f += n_items;

    c_ipi.resize(n_items, 0);
    for (size_t i = 0; i < c_ipi.size(); ++i) {
      c_item[i] = n_c + i;
    }
    n_c += n_items;
  }

  // retention interval distraction
  if (param.Bri > 0) {
    f_ri.resize(1, 0);
    f_ri[0] = n_f;
    n_f += 1;

    c_ri.resize(1, 0);
    c_ri[0] = n_c;
    n_c += 1;
  }

  // list start unit
  f_start.resize(1, 0);
  f_start[0] = n_f;
  n_f += 1;

  c_start.resize(1, 0);
  c_start[0] = n_c;
  n_c += 1;

  // non-item units
  n_other = f_ipi.size() + f_ri.size() + f_start.size();
  f_other.resize(n_other, 0);
  for (size_t i = 0; i < f_other.size(); ++i) {
    f_other[i] = n_items + i;
  }
  c_other.resize(n_other, 0);
  for (size_t i = 0; i < c_other.size(); ++i) {
    c_other[i] = n_units + i;
  }
  
  // initialize layers
  c = Context(n_c, param.Benc);
  cin_exp = Context(n_c);
  cin_pre = Context(n_c);
  f = Context(n_f);
  c_rec_init = Context(n_c);

  // recall competition
  a.resize(n_items);
  p.resize(n_items+1);

  // weights
  wfc_exp = Weights(n_f, n_c, 0, 0);
  wcf_exp = Weights(n_f, n_c, 0, 0);
  if (isdc) {
    wfc_pre = Weights(n_f, n_c, param.Afc);
    wcf_pre = Weights(n_f, n_c, param.Acf);
  } else {
    wfc_pre = Weights(n_f, n_c, param.Afc, param.Dfc);
    wcf_pre = Weights(n_f, n_c, param.Acf, param.Dcf);
  }
  wcf_sem = Weights(n_f, n_c, 0, 0);

  // set pre-experimental weights between non-item units and items to zero
  for (size_t i = 0; i < n_other; ++i) {
    // cols
    for (size_t j = 0; j < wcf_pre.connect.size(); ++j) {
      wcf_pre.connect[j][c_other[i]] = 0;
    }
    // rows
    for (size_t j = 0; j < wcf_pre.connect[i].size(); ++j) {
      wcf_pre.connect[f_other[i]][j] = 0;
    }
  }
  
  // store initial states of c_study and wcf
  wfc_exp_init = wfc_exp;
  wfc_pre_init = wfc_pre;
  wcf_exp_init = wcf_exp;
  wcf_pre_init = wcf_pre;
}

void Network::setSem (vector<unsigned int> * poolno, vector< vector<double> > * poolsem) {
  if (param.Scf != 0) {
    for (unsigned int i = 0; i < n_f_item; ++i) {
      for (unsigned int j = 0; j < n_c_item; ++j) {
	wcf_sem.connect[i][j] = (*poolsem)[(*poolno)[i]-1][(*poolno)[j]-1] * param.Scf;
      }
    }
  }
}

void Network::setVec (vector<unsigned int> * vecno, vector< vector<double> > * vecsem) {
  if (param.Dfc != 0) {
    for (unsigned int i = 0; i < n_f_item; ++i) {
      for (unsigned int j = 0; j < n_c_item; ++j) {
	wfc_pre.connect[i][j] += (*vecsem)[j][(*vecno)[i]-1] * param.Dfc;
      }
    }
  }
  
  if (param.Dcf != 0) {
    for (unsigned int i = 0; i < n_f_item; ++i) {
      for (unsigned int j = 0; j < n_c_item; ++j) {
	wcf_pre.connect[i][j] += (*vecsem)[j][(*vecno)[i]-1] * param.Dcf;
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
  cin_pre.setUnit(unit);
  c.updateOrthog(&cin_pre);
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
  cin_exp.setUnit(c_start[0]);
  c.update(&cin_exp);
}

void Network::resetRecall () {
  f.setUnit(n_f_item-1);
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
  for (unsigned int i = 0; i < n_f_item; ++i) {
    a[i] = 0;
    for (unsigned int j = 0; j < n_c; ++j) {
      a[i] += context[j] * (wcf_exp.connect[i][j] + wcf_pre.connect[i][j]);
    }
    a[i] = pow(max(a[i], param.amin), param.T);
  }
}

void Network::cueItemSem () {
  double * context = c.getStatePtr();
  for (unsigned int i = 0; i < n_f_item; ++i) {
    a[i] = 0;

    // item units
    for (unsigned int j = 0; j < n_c_item; ++j) {
      a[i] += context[j] * (wcf_exp.connect[i][j] + wcf_pre.connect[i][j] + wcf_sem.connect[i][j]);
    }

    // other units
    for (unsigned int j = 0; j < n_other; ++j) {
      a[i] += context[c_other[j]] * wcf_exp.connect[i][c_other[j]];
    }

    // transformed activation
    a[i] = pow(max(a[i], param.amin), param.T);
  }
}

void Network::cueItemSemSplit (double I) {
  double * context = c.getStatePtr();
  double * item = f.getStatePtr();
  for (unsigned int i = 0; i < n_f_item; ++i) {
    a[i] = 0;

    // item units
    for (unsigned int j = 0; j < n_c_item; ++j) {
      a[i] += context[j] * (wcf_exp.connect[i][j] + wcf_pre.connect[i][j]);
      a[i] += (context[j] * (1 - I) + item[j] * I) * wcf_sem.connect[i][j];
    }

    // other units
    for (unsigned int j = 0; j < n_other; ++j) {
      a[i] += context[c_other[j]] * wcf_exp.connect[i][c_other[j]];
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
  if (output_pos == n_f_item) {
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
      double asize = static_cast<double>(n_f_item);
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
