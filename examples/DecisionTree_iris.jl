"""
An example on how to use the `TreeRecipe` with `DecisionTree.jl` on the Iris data set
in order to get a visually pleasing plot of the resulting decision tree.
"""

using DecisionTree      
using Plots  
using TreeRecipe

# load and prepare the Iris data set
features, labels = load_data("iris") 
features = float.(features)
labels   = string.(labels)

# train a DecisionTree on the Iris data set
model = DecisionTreeClassifier()
fit!(model, features, labels)

# print the resulting decision tree in textual form
print_tree(model, 5)

# add feature names to the tree structure and prepare it for plotting (with `wrap`)
feature_names = ["sepal length", "sepal width", "petal length", "petal width"]
dtree = model.root.node
wt = DecisionTree.wrap(dtree, (featurenames = feature_names,))

# plot the decision tree (implicitly calling the `TreeRecipe` plot recipe)
# `width` and `height` of the node rectangles as well as the `size` of the 
# plotting area are adapted in order to get a visually pleasing output
plot(wt, 0.8, 0.7; size = (1400,600))