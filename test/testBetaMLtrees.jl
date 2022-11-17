"""
Example on how to use the `TreeRecipe` with a decision tree from the BetaML-package.
These decision trees typically "know" the classnames, so only featurenames have to be added.
"""

using BetaML      
using Plots  
using TreeRecipe

xtrain = [
    "Green"  3.0;
    "Yellow" 3.0;
    "Red"    1.0;
    "Red"    1.0;
    "Yellow" 3.0;
]
ytrain = ["Apple",  "Apple", "Grape", "Grape", "Lemon"]

# train (and build) a decision tree
m = DecisionTreeEstimator()
yhat_train = fit!(m, xtrain, ytrain)
dte = m.par.tree

# add information about feature names 
feature_names = ["Color", "Intensity"]
wt = BetaML.wrap(dt, (featurenames = feature_names, ))

# plot the tree using the `TreeRecipe`
plot(wt)        # this calls automatically the `TreeRecipe`