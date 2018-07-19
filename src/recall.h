#ifndef RECALL_H_
#define RECALL_H_

#include <vector>

#include "network.h"
#include "parameters.h"
#include "paramArray.h"

/**
 * @short Class for simulating a free recall task.
 *
 * Implements a single-trial free recall task; for provided recall
 * sequences, calculates the probability of each recall event
 * (including recalling a specific item, or stopping recall).
 */

class Recall {
  unsigned int list_length;
  unsigned int n_lists;
  ParamArray param_array;
  Network net;
  bool has_sem;
  bool has_vec;
  std::vector<unsigned int> r;
  std::vector< std::vector<unsigned int> > r_mat;
  std::vector< std::vector<unsigned int> > i_mat;
  std::vector<unsigned int> index;
  std::vector< std::vector<double> > p;
  std::vector<unsigned int> r_list;
  std::vector<unsigned int> i_list;
  std::vector<unsigned int> r_prev;
  std::vector< std::vector<unsigned int> > * poolno;
  std::vector< std::vector<double> > * poolsem;
  std::vector< std::vector<unsigned int> > * vecno;
  std::vector< std::vector<double> > * vecsem;
 public:
  /**
   * Blank constructor.
   */
  Recall ();

  /**
   * Standard constructor.
   *
   * @param N number of items in each list.
   * @param param model parameters.
   *
   * @param recalls vector of recall event codes. Correct recalls are
   * indicated by the serial position of the recalled item. The code
   * [N+1] indicates a stopping event.
   */
  Recall (unsigned int n_items, unsigned int n_units, bool isdc,
	  Parameters param, std::vector<unsigned int> recalls);

  /**
   * Constructor with support for multiple parameter sets.
   *
   * @param N number of items in each list.
   * @param param_set array of parameters for different conditions.
   * @param recalls vector of recall event codes.
   *
   * @param index_vector vector giving the index of the parameters to
   * use for each list. May indicate different parameters for
   * different conditions, participants, etc.
   */
  Recall (unsigned int n_items, unsigned int n_units, bool isdc,
	  ParamArray param_set,
	  std::vector<unsigned int> recalls, 
	  std::vector<unsigned int> index_vector);

  /**
   * Determine the number of lists contained in the input data.
   */
  void setNLists ();

  /**
   * Rearrange recall event codes in matrix format.
   */
  void extractLists ();

  /**
   * Run sanity checks on recall event codes.
   */
  void checkRecallCodes ();

  /**
   * Present a list of items to the network.
   */
  void presentList ();

  /**
   * Set semantic similarity and item numbers for the stimulus pool.
   */
  void setPoolSim (std::vector< std::vector<unsigned int> > * itemno,
		   std::vector< std::vector<double> > * item_sem);

  /**
   * Set semantic vectors and item numbers for the stimulus pool.
   */
  void setPoolVec (std::vector< std::vector<unsigned int> > * itemno,
		   std::vector< std::vector<double> > * item_sem);

  /**
   * Simulate a recall period and calculate recall event probabilites.
   */
  void recallPeriod (unsigned int list);

  /**
   * Simulate a recall period and calculate recall event probabilites.
   */
  void recallPeriodSem (unsigned int list);

  /**
   * Run a free recall task, based on a sequence of recall event codes.
   */
  void task ();

  /**
   * Run free recall, assuming that only semantic similarity varies.
   *
   * Runs a streamlined version of the model, which only simulates the
   * study period once for each parameter set. Semantic similarity
   * only affects the recall period, so item identity may vary between
   * list. Other types of variation between lists may require using
   * task to simulate each study period separately.
   *
   * For speed, also assumes that items are orthogonal to each other
   * and to the beginning of list context, and that no items are
   * repeated during encoding.
   */
  void taskSameList ();

  /**
   * Print all recall event probabilities.
   */
  void printProb ();

  /**
   * Run sanity checks on recall event probabilities.
   */
  bool checkProb ();

  /**
   * Get all recall event probabilties.
   *
   * @param p vector of vectors, where p[i][j] gives the probability
   * of recall event j on recall attempt i. When j < list length, this
   * is the probability of recalling the item at serial position
   * [j+1]. Stop probability is indicated by j = list length.
   */
  std::vector< std::vector<double> > getProb ();

  /**
   * Calculate log likelihood for a set of recall events.
   */
  double logL ();

  /**
   * Get the number of recall events being simulated.
   */
  unsigned int getNRecalls ();
};

#endif
