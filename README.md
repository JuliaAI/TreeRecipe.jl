[![Build status (Github Actions)](https://github.com/JuliaAI/TreeRecipe.jl/workflows/CI/badge.svg)](https://github.com/JuliaAI/TreeRecipe.jl/actions)
[![codecov.io](http://codecov.io/github/JuliaAI/TreeRecipe.jl/coverage.svg?branch=main)](http://codecov.io/github/JuliaAI/TreeRecipe.jl?branch=main)

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
an exemplary implementation of the concept. In addition there are examples in the `examples`-folder which show how the recipe can be applied to plot decision trees from the `DecisionTree.jl`-package as well as from the `BetaML.jl`-package.

This approach taken by `TreeRecipe` ensures that a tree implementation can be plotted without having any dependencies to a graphics package and it ensures furthermore, that the recipe is independent of the implementation details of the tree. 

For more information have a look at the article 
["If things are not ready to use"](https://towardsdatascience.com/part-iii-if-things-are-not-ready-to-use-59d2db378bec) in *Towards Data Science* where the basic ideas are explained.

And here you get an impression on how a plot of a decision tree might look like (in this case a `DecsionTree` with the Iris dataset):

<img width="898" alt="image" src="https://user-images.githubusercontent.com/80126696/206247398-ef30b6e2-8fb8-4228-9d35-2bcb7d82bc34.png">
