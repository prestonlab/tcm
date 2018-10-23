#include <sstream>
#include <iostream>
#include <iomanip>

#include "parameters.h"

using namespace std;

const double AMIN = .000001;
const double PMIN = .000001;

Parameters::Parameters () {
  Benc = 0.9;
  Brec = 0.6;
  X1 = 0.001;
  X2 = 0.3;
  P1 = 2;
  P2 = 1;
  T = 1;
  Afc = 0;
  Dfc = 1;
  Sfc = 0;
  Lfc = 1;
  Acf = 0;
  Dcf = 1;
  Scf = 0;
  Lcf = 1;
  stop = 1;
  Bstart = 0;
  Bipi = 0;
  Bri = 0;
  I = 0;
  init_item = 1;
  amin = AMIN;
  pmin = PMIN;
}

Parameters::Parameters (vector<double> &param_vec) {
  Benc = param_vec[0];
  Brec = param_vec[1];
  Afc = param_vec[2];
  Dfc = param_vec[3];
  Sfc = param_vec[4];
  Lfc = param_vec[5];
  Acf = param_vec[6];
  Dcf = param_vec[7];
  Scf = param_vec[8];
  Lcf = param_vec[9];
  P1 = param_vec[10];
  P2 = param_vec[11];
  T = param_vec[12];
  X1 = param_vec[13];
  X2 = param_vec[14];
  stop = param_vec[15];
  Bstart = param_vec[16];
  Bipi = param_vec[17];
  Bri = param_vec[18];
  I = param_vec[19];
  init_item = param_vec[20];

  amin = AMIN;
  pmin = PMIN;
}

// string Parameters::toString (string name, double val) const {
//   ostringstream ss;
//   string s;
//   ss << fixed << setprecision(4) << val;
//   s = name + " = " + ss.str() + "\n";
//   return s;
// }

// void Parameters::print () const {
//   string s = "";
//   s += toString("Benc", Benc);
//   s += toString("Brec", Brec);
//   s += toString("Afc", Afc);
//   s += toString("Dfc", Dfc);
//   s += toString("Sfc", Sfc);
//   s += toString("Lfc", Lfc);
//   s += toString("Acf", Acf);
//   s += toString("Dcf", Dcf);
//   s += toString("Scf", Scf);
//   s += toString("Lcf", Lcf);
//   s += toString("P1", P1);
//   s += toString("P2", P2);
//   s += toString("T", T);
//   s += toString("X1", X1);
//   s += toString("X2", X2);
//   s += toString("stop", stop);
//   s += toString("Bstart", Bstart);
//   s += toString("Bri", Bri);
//   s += toString("I", I);
//   s += toString("Init item", init_item);
//   s += toString("amin", amin);
//   s += toString("pmin", pmin);

//   cout << s;
// }
