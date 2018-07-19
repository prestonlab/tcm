#include <iostream>
#include <iomanip>
#include <cmath>

#include "context.h"

using namespace std;

Context::Context () {}

Context::Context (unsigned int n_units) {
  state.resize(n_units, 0);
}

Context::Context (unsigned int n_units, double beta) {
  B = beta;
  state.resize(n_units, 0);
}

void Context::clear () {
  for (size_t i = 0; i < state.size(); ++i) {
    state[i] = 0;
  }
}

void Context::setUnit (unsigned int unit) {
  clear();
  state[unit] = 1;
}

void Context::setState (vector<double> &c) {
  for (size_t i = 0; i < state.size(); ++i) {
    state[i] = c[i];
  }
}

void Context::print () {
  for (size_t i = 0; i < state.size(); ++i) {
    cout << fixed << setprecision(4) << state[i] << ' ';
  }
  cout << endl;
}

double Context::dot (Context *cin) {
  // below works with JAGS install, but takes about the same time to
  // run, so sticking with the version that doesn't rely on LAPACK
  //int one = 1, N = state.size();
  //return F77_DDOT(&N, &state[0], &one, &cin->state[0], &one);

  double value = 0;
  for (size_t i = 0; i < state.size(); ++i) {
    value += state[i] * cin->state[i];
  }
  return value;
}

void Context::normalize () {
  double norm = 0;
  for (size_t i = 0; i < state.size(); ++i) {
    norm += pow(state[i], 2);
  }
  norm = sqrt(norm);

  for (size_t i = 0; i < state.size(); ++i) {
    state[i] /= norm;
  }
}

void Context::combine (Context *cin, double B1, double B2) {
  for (size_t i = 0; i < state.size(); ++i) {
    state[i] = B1 * state[i] + B2 * cin->state[i];
  }
}

void Context::update (Context *cin) {
  double cdot, rho;
  cdot = dot(cin);
  rho = sqrt(1 + pow(B, 2) * (pow(cdot, 2) - 1)) - (B * cdot);
  combine(cin, rho, B);
}

void Context::updateOrthog (Context *cin) {
  combine(cin, sqrt(1 - pow(B, 2)), B);
}

vector<double> Context::getState () {
  return state;
}

double * Context::getStatePtr () {
  return &state[0];
}

double Context::getUnit (unsigned int unit) {
  return state[unit];
}

void Context::setB (double Bnew) {
  B = Bnew;
}

