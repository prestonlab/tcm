#include <iostream>
#include <iomanip>
#include <vector>
#include "weights.h"
#include "context.h"

using namespace std;

Weights::Weights () {};

Weights::Weights (unsigned int N, unsigned int M, double base, double diag) {
  n_in = N;
  n_out = M;
  L = 1;
  connect.resize(n_in);
  for (size_t i = 0; i < connect.size(); ++i) {
    connect[i].resize(n_out, base);
    connect[i][i] += diag;
  }
}

void Weights::learnOrthog (unsigned int unit, Context &c) {
  for (size_t i = 0; i < connect[unit].size(); ++i) {
    connect[unit][i] += c.getUnit(i) * L;
  }
}

void Weights::project (Context &cin, Context &cout) {
  for (unsigned int i = 0; i < n_in; ++i) {
    cout.state[i] = 0;
    for (unsigned int j = 0; j < n_out; ++j) {
      cout.state[i] += cin.state[j] * connect[i][j];
    }
  }
}

void Weights::projectOrthog (unsigned int unit, Context &cout) {
  cout.state = connect[unit];
}

void Weights::print () {
  for (size_t i = 0; i < n_in; ++i) {
    for (size_t j = 0; j < n_out; ++j) {
      cout << fixed << setprecision(4) << connect[i][j] << ' ';
    }
    cout << endl;
  }
  cout << endl;
}
