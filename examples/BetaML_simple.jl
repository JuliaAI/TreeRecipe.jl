"""
An example on how to use the `TreeRecipe` with `BetaML.jl` decison trees
on a simple data set.
"""

using BetaML
using Plots 
using TreeRecipe

# a tiny and simple dataset
xtrain = [
    "Green"  3.0;
    "Yellow" 3.0;
    "Red"    1.0;
    "Red"    1.0;
    "Yellow" 3.0;
]
ytrain = ["Apple",  "Apple", "Grape", "Grape", "Lemon"]

# train a `DecisionTreeEstimator` on this dataset
model = DecisionTreeEstimator()
yhat_train = Trees.fit!(model, xtrain, ytrain)

# print the resulting decision tree in textual form
println(model)

# add feature names to the tree structure and prepare it for plotting (with `wrap`)
feature_names = ["Color", "Intensity"]
dtree = model.par.tree
wrapped_tree = Trees.wrap(dtree, (featurenames = feature_names, ))

# plot the decision tree (implicitly calling the `TreeRecipe` plot recipe)
# `width` and `height` of the node rectangles are adapted in order to get 
# a visually pleasing output
plt = plot(wrapped_tree, 0.4, 0.5)       