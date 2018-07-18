#include <vector>
#include <iostream>
#include <cmath>
#include <cassert>
#include <string>
#include <sstream>
#include <stdexcept>
#include "network.cc"
#include "parameters.h"
#include "recall.h"

using namespace std;

Recall::Recall () {};

Recall::Recall (unsigned int n_items, unsigned int n_units,
		Parameters model_param, vector<unsigned int> recalls) {
  // initialize parameters
  param_array.add(model_param);

  // create network with standard f and c representations and weights
  list_length = n_items;
  net = Network(n_items, n_units, model_param);

  // set recalls vector
  r = recalls;

  // unpack lists
  setNLists();
  index.resize(n_lists, 0);
  extractLists();

  // prepare probability matrix
  p.resize(r.size());
  for (size_t i = 0; i < r.size(); ++i) {
    p[i].resize(n_items+1);
  }
  has_sem = false;
}

Recall::Recall (unsigned int n_items, unsigned int n_units,
		ParamArray param_set, vector<unsigned int> recalls,
		vector<unsigned int> index_vector) {
  Parameters param;

  list_length = n_items;
  param_array = param_set;
  index = index_vector;
  n_lists = index.size();
  param = param_array.getParam(0);
  net = Network(n_items, n_units, param);
  r = recalls;
  extractLists();
  p.resize(r.size());
  for (size_t i = 0; i < r.size(); ++i) {
    p[i].resize(n_items+1);
  }
  has_sem = false;
}

void Recall::setNLists () {
  // one list for each recall termination event
  n_lists = 0;
  for (size_t i = 0; i < r.size(); ++i) {
    if (r[i] == list_length + 1) {
      ++n_lists;
    }
  }
}

void Recall::extractLists () {
  unsigned int list = 0;

  // convert recalls vector and index vector to [lists x items] format
  r_mat.resize(n_lists);
  i_mat.resize(n_lists);

  for (size_t i = 0; i < r.size(); ++i) {
    r_list.push_back(r[i]);
    i_list.push_back(i);
    if (r[i] == list_length + 1) {
      r_mat[list] = r_list;
      i_mat[list] = i_list;
      ++list;
      r_list.clear();
      i_list.clear();
    }
  }
}

void Recall::checkRecallCodes () {
  for (unsigned int i = 0; i < r.size(); ++i) {
    if (r[i] < 1 || r[i] > (list_length + 1)) {
      ostringstream ss;
      ss << r[i];
      string msg = "Bad recall code: " + ss.str();
      throw runtime_error(msg);
    }
  }
}

void Recall::presentList () {
  double prim;
  for (unsigned int i = 0; i < list_length; ++i) {
    // TODO: use Lcf instead of 1, to allow changing the base learning
    // rate
    prim = (net.param.P1 * exp(-net.param.P2 * static_cast<double>(i))) + 1;
    net.setLcf(prim);
    net.presentItem(i);
  }
}

void Recall::setPoolSim (vector< vector<unsigned int> > * itemno, vector< vector<double> > * item_sem) {
  // just copy pointers to the recall object
  poolno = itemno;
  poolsem = item_sem;
  has_sem = true;
}

void Recall::recallPeriod (unsigned int list) {
  double output_pos;
  for (size_t i = 0; i < r_list.size(); ++i) {
    net.cueItem();
    output_pos = static_cast<double>(i);
    net.pstop(output_pos);
    net.removeRepeats();
    net.recallComp();
    
    p[i_list[i]] = net.getProb();
    if (i < (r_list.size() - 1)) {
      net.reactivateItem(r_list[i] - 1);
    }
  }
}

void Recall::recallPeriodSem (unsigned int list) {
  double output_pos;
  for (size_t i = 0; i < r_list.size(); ++i) {
    if (i > 0 || net.param.init_item) {
      // if a recall has already been made, or if using the last item
      // on the list as a cue, include item information in the
      // semantic cue
      net.cueItemSemSplit(net.param.I);
    } else if (net.param.I == 1) {
      // it's the first recall, not using the last item as a cue, and
      // never using context as a semantic cue. Just cue with context
      // through episodic associations only
      net.cueItem();
    } else {
      // it's the first recall, not using the last item as a cue, but
      // am using context as a semantic cue
      net.cueItemSem();
    }
    output_pos = static_cast<double>(i);
    net.pstop(output_pos);
    net.removeRepeats();
    net.recallComp();

    p[i_list[i]] = net.getProb();
    if (i < (r_list.size() - 1)) {
      net.reactivateItem(r_list[i] - 1);
    }
  }
}

void Recall::task () {
  for (unsigned int i = 0; i < n_lists; ++i) {
    // initialize the network
    net.clear();
    net.param = param_array.getParam(index[i]);
    if (has_sem) {
      net.setSem(&(*poolno)[i], poolsem);
    }
    net.setB(1);
    net.presentDistract(net.f_start[0]);

    // present the list
    net.setB(net.param.Benc);
    presentList();
    
    // retention interval context disruption
    if (net.param.Bri != 0) {
      net.setB(net.param.Bri);
      net.presentDistract(net.f_ri[0]);
    }
      
    // reinstate start-of-list context
    if (net.param.Bstart != 0) {
      net.setB(net.param.Bstart);
      net.reactivateStart();
    }

    // calculate and store recall probabilities for this list
    net.setB(net.param.Brec);
    r_list = r_mat[i];
    i_list = i_mat[i];
    if (has_sem) {
      recallPeriodSem(i);
    } else {
      recallPeriod(i);
    }
  }
}

void Recall::taskSameList () {
  unsigned int curr_index;
  unsigned int prev_index;
  for (unsigned int i = 0; i < n_lists; ++i) {
    curr_index = index[i];
    if (i == 0 || curr_index != prev_index) {
      // this is the start of a new subject
      net.param = param_array.getParam(curr_index);

      // initialize the network
      net.clear();
      if (has_sem) {
	net.setSem(&(*poolno)[i], poolsem);
      }
      net.setB(1);
      net.presentDistract(net.f_start[0]);

      // present the list
      net.setB(net.param.Benc);
      presentList();

      // retention interval context disruption
      if (net.param.Bri != 0) {
	net.setB(net.param.Bri);
	net.presentDistract(net.f_ri[0]);
      }
      
      // reinstate start-of-list context
      if (net.param.Bstart != 0) {
	net.setB(net.param.Bstart);
	net.reactivateStart();
      }

      // prepare the network for recall
      net.setB(net.param.Brec);

      // save the cue just before recall
      net.storeCue();
    } else {
      // this list is the same as the others for this index value;
      // just reactivate the start-of-recall context and go from there
      net.resetRecall();
      if (has_sem) {
	net.setSem(&(*poolno)[i], poolsem);
      }
    }

    // calculate and store recall probabilities for this list
    r_list = r_mat[i];
    i_list = i_mat[i];
    if (has_sem) {
      recallPeriodSem(i);
    } else {
      recallPeriod(i);
    }
    prev_index = curr_index;
  }
}

void Recall::printProb () {
  for (size_t i = 0; i < p.size(); ++i) {
    for (size_t j = 0; j < p[i].size(); ++j) {
      cout << fixed << setprecision(4) << p[i][j] << ' ';
    }
    cout << endl;
  }
  cout << endl;
}

bool Recall::checkProb () {
  double x;
  bool isgood = true;
  for (size_t i = 0; i < p.size(); ++i) {
    x = 0;
    for (size_t j = 0; j < p[i].size(); ++j) {
      if (isnan(p[i][j])) {
	isgood = false;
      }
      x += p[i][j];
    }
    if (x <= 0) {
      isgood = false;
    }
    for (size_t j = 0; j < p[i].size(); ++j) {
      p[i][j] /= x;
    }
  }
  return isgood;
}

vector< vector<double> > Recall::getProb () {
  return p;
}

unsigned int Recall::getNRecalls () {
  return r.size();
}

double Recall::logL () {
  double logl = 0;
  for (size_t i = 0; i < r.size(); ++i) {
    logl += log(p[i][r[i] - 1]);
  }
  return logl;
}
