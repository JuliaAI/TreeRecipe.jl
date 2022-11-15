# TreeRecipe.jl

A Plot recipe for plotting (decision) trees.

A plot recipe (based on `RecipeBase.jl`) to create a graphical representation of a tree.
The recipe has originally been designed to plot decision trees, but it is able to plot all sort
of trees which conform to the following rules:

- The tree must be wrapped in an `AbstractTrees`-interface. I.e. it has
  - to be a subtype of `AbstractTrees.AbstractNode{T}`
  - implement `AbstractTrees.children()`
  - implement `AbstractTrees.printnode()`

See [`DecisionTree.jl/abstract_trees.jl`](https://github.com/JuliaAI/DecisionTree.jl/blob/9dab9c12fcf2d54d4591b23fc87512964fb664b8/src/abstract_trees.jl) for 
an exemplary implementation of the concept. In addition there is an example in `test/runstests.jl` that shows how the recipe can be applied to plot a `DecisionTree`.

This approach ensures that a tree implementation can be plotted without having any dependencies to a graphics package and it ensures furthermore, that the recipe is independent of the implementation details of the tree. 

For more information have a look at the article 
["If things are not ready to use"](https://towardsdatascience.com/part-iii-if-things-are-not-ready-to-use-59d2db378bec) in *Towards Data Science* where the basic ideas are explained.