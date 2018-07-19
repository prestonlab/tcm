#ifndef WEIGHTS_H_
#define WEIGHTS_H_

#include <vector>

#include "context.h"

/**
 * @short Weights connecting distributed representations.
 *
 * Represents connection weights between two layers. Includes methods
 * for initializing and updating connection weights.
 */

class Weights {
  unsigned int n_in;
  unsigned int n_out;
 public:
  std::vector< std::vector<double> > connect; ///< Matrix of connection weights
  double L; ///< Current learning rate
  /**
   * Blank constructor.
   */
  Weights ();

  /**
   * Constructor indicating number of units and initial weights.
   *
   * @param N number of units for the input layer.
   * @param M number of units for the output layer.
   * @param base connection strength for off-diagonal entries.
   * @param diag connection strength for diagonal entries.
   */
  Weights (unsigned int N, unsigned int M, double base, double diag);

  /**
   * Constructor indicating number of units and initial weights.
   *
   * @param N number of units for the input layer.
   * @param M number of units for the output layer.
   * @param base connection strength for off-diagonal entries.
   */
  Weights (unsigned int N, unsigned int M, double base);

  /**
   * Add semantic association strengths to weights.
   *
   * @param sem matrix of semantic association strengths.
   * @param itemno position of each item in the semantic matrix, using 1-indexing. The semantic connection between units i and j is given in sem[itemno[i]-1][itemno[j]-1].
   * @param D value to add to diagonal entries.
   */
  void addSem (std::vector< std::vector<double> > &sem,
	       std::vector<unsigned int> &itemno,
	       double D);

  /**
   * Learn an association between a localist item representation and a distributed context representation.
   *
   * @param unit index of the unit of the localist item representation that is active.
   * @param c current state of context.
   */
  void learnOrthog (unsigned int unit, Context &c);

  /**
   * Project a state of context through associative connections.
   *
   * @param cin input state of context.
   * @param cout result of projecting through the connections.
   */
  void project (Context &cin, Context &cout);

  /**
   * Project a localist item representation through associative connections.
   *
   * @param unit index of the unit of the localist item representation that is active.
   * @param cout result of projecting through the connections.
   */
  void projectOrthog (unsigned int unit, Context &cout);

  /**
   * Print the current connection weights.
   */
  void print ();
};

#endif
