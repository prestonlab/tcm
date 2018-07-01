#ifndef CONTEXT_H_
#define CONTEXT_H_

/**
 * @short Distributed representation of temporal context
 *
 * Representation of a state of temporal context. Includes methods for
 * setting and updating the state of context based on input from
 * presented stimuli.
 */

class Context {
 public:
  double B; ///< Current integration rate
  std::vector<double> state; ///< Activity values of units of the context layer
  /**
   * Blank constructor.
   */
  Context ();

  /**
   * Constructor with no integration rate specified.
   *
   * @param n_units number of units for the context layer.
   */
  Context (unsigned int n_units);

  /**
   * Constructor with integration rate.
   *
   * @param n_units number of units for the context layer.
   * @param beta integration rate.
   */
  Context (unsigned int n_units, double beta);

  /**
   * Clear the current state of context.
   */
  void clear ();

  /**
   * Activate a single unit of context.
   *
   * @param unit index of the unit to activate.
   */
  void setUnit (unsigned int unit);

  /**
   * Set the state of context.
   *
   * @param c vector of doubles indicating the new state.
   */
  void setState (std::vector<double> &c);

  /**
   * Print the current state of context to standard output.
   */
  void print ();

  /**
   * Dot product between the current context and incoming context.
   *
   * @param cin incoming state of context.
   * @param value result of the dot product.
   */
  double dot (Context *cin);

  /**
   * Normalize the context vector to have length 1.
   */
  void normalize ();

  /**
   * Combine the current context with incoming context.
   *
   * @param cin incoming state of context.
   * @param B1 weight for the current state.
   * @param B2 weight for the incoming state.
   */
  void combine (Context *cin, double B1, double B2);

  /**
   * Update the state of context.
   *
   * @param cin incoming sate of context.
   */
  void update (Context *cin);

  /**
   * Update context with an orthogonal incoming context.
   *
   * Only use this if the incoming context is orthogonal to the
   * current state of context; this is the case, for example, during
   * the study period as long as no items are repeated.
   *   
   * @param cin incoming state of context.
   * @see update()
   */
  void updateOrthog (Context *cin);

  /**
   * Get the current state of context.
   *
   * @param state vector with activation values for each unit of context.
   */
  std::vector<double> getState ();
	
  /**
   * Get a pointer to the current state of context.
   *
   * @param state pointer to the context activation vector.
   */
  double * getStatePtr ();

  /**
   * Get the activation of a unit in the context layer.
   *
   * @param unit index of the unit to access.
   */
  double getUnit (unsigned int unit);

  /**
   * Set the integration rate of the context layer.
   *
   * @param Bnew new integration rate.
   */
  void setB (double Bnew);
};

#endif
