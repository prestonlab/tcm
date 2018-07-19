#ifndef NETWORK_H_
#define NETWORK_H_

#include "context.h"
#include "parameters.h"
#include "weights.h"

/**
 * @short Representation of context maintenance and retrieval network.
 *
 * Network representing stimuli, temporal context, and connections
 * between the two layers.
 */

class Network {
  Context cin_exp; ///< Context input based on experimental weights.
  Context cin_pre; ///< Context input based on pre-experimental weights.
  Context c_rec_init; ///< Context at the beginning of recall.
  Weights wfc_exp_init; ///< Experimental Wfc weights at beginning of list.
  Weights wcf_exp_init; ///< Experimental Wcf weights at beginning of list.
  Weights wfc_pre_init; ///< Pre-experimental Wfc weights at beginning of list.
  Weights wcf_pre_init; ///< Pre-experimental Wcf weights at beginning of list.
  std::vector<double> a; ///< Activation of items on F.
  std::vector<double> p; ///< Probability of recalling each item.
  std::vector<unsigned int> r_prev; ///< Indices of previously recalled items.
  std::vector< std::vector<double> > c_study; ///< States of context during study.
 public:
  unsigned int n_f;
  unsigned int n_c;
  unsigned int n_f_item;
  unsigned int n_c_item;
  unsigned int n_other;
  std::vector<unsigned int> f_item;
  std::vector<unsigned int> c_item;
  std::vector<unsigned int> f_ipi;
  std::vector<unsigned int> c_ipi;
  std::vector<unsigned int> f_ri;
  std::vector<unsigned int> c_ri;
  std::vector<unsigned int> f_start;
  std::vector<unsigned int> c_start;
  std::vector<unsigned int> f_other;
  std::vector<unsigned int> c_other;
  Context f;
  Context c;
  Weights wfc_exp;
  Weights wfc_pre;
  Weights wcf_exp;
  Weights wcf_pre;
  Weights wcf_sem;
  Parameters param; ///> Model parameter set.

  /**
   * Blank constructor.
   */
  Network ();

  /**
   * Constructor specifying the layer size and parameters.
   *
   * @param n_items number of items to be presented.
   * @param n_units number of item units in the context layer.
   * @param model_param model parameters
   */
  Network (unsigned int n_items, unsigned int n_units, bool isdc,
	   Parameters model_param);

  /**
   * Add semantic associations to connection weights.
   *
   * @param poolno index of each item in the semantic matrix.
   * @param poolsem matrix of semantic association strengths.
   */
  void setSem (vector<unsigned int> * poolno,
	       vector< vector<double> > * poolsem);

  /**
   * Add semantic vectors to pre-experimental connection weights.
   *
   * @param vecno index of each item in the vector matrix.
   * @param vecsem matrix of semantic vectors.
   */
  void setVec (vector<unsigned int> * vecno,
	       vector< vector<double> > * vecsem);

  /**
   * Clear model layers and connection weights.
   */
  void clear ();

  /**
   * Store context in the record and in connection weights.
   *
   * @param unit index of the unit to store the current state of context in.
   */
  void storeContext (unsigned int unit);

  /**
   * Store the current state of context for later use as a cue.
   */
  void storeCue ();

  /**
   * Get the last stored context cue.
   */
  void getCue ();

  /**
   * Update context with input from the item layer, without learning.
   *
   * @param unit index of the item unit to activate before updating.
   * @see presentItem
   */
  void presentDistract (unsigned int unit);

  /**
   * Update context with input from the item layer, and learn connections.
   *
   * @param unit index of the item unit to activate before updating.
   * @see presentDistract
   * @see reactivateItem
   */
  void presentItem (unsigned int unit);

  /**
   * Reactivate a recalled item and update context.
   *
   * @param unit index of the recalled item in the item layer.
   * @see presentItem
   */
  void reactivateItem (unsigned int unit);

  /**
   * Reactivate start-of-list context.
   */
  void reactivateStart ();

  /**
   * Reset the network for a new recall period.
   */
  void resetRecall ();

  /**
   * Set the integration rate of the context layer.
   *
   * @param Bnew new integration rate.
   */
  void setB (double Bnew);

  /**
   * Set the learning rate for context-to-item associations.
   *
   * @param L learning rate.
   */
  void setLcf (double L);

  /**
   * Cue for an item using the current state of context.
   */
  void cueItem ();

  /**
   * Cue for an item using the current state of context and semantics.
   */
  void cueItemSem ();

  /**
   * Cue using a mix of item and context information.
   *
   * @param I weighting of item information. (1-I) gives weighting for context.
   */
  void cueItemSemSplit (double I);

  /**
   * Set activation of previously recalled items to zero.
   */
  void removeRepeats ();

  /**
   * Calculate the probability of stopping recall.
   *
   * @param output_pos position in the output sequence (the number of previous recalls; e.g. 0 for the first recall attempt)
   */
  void pstop (double output_pos);

  /**
   * Calculate the probability of recalling each item.
   */
  void recallComp ();

  /**
   * Get probabilities of recalling each item and of stopping.
   *
   * @param p recall event probabilities; the last element gives stop probability
   */
  std::vector<double> getProb ();

  /**
   * Print information about the state of the network.
   */
  void printState ();

  /**
   * Print the current state of context.
   */
  void printContext ();

  /**
   * Print the current input to context.
   */
  void printContextIn ();
};

#endif
