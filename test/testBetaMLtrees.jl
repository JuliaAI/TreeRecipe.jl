using Pkg
Pkg.develop(PackageSpec(path = ("/Users/roland/Library/CloudStorage/OneDrive-adviionGmbH/__Projekte/Julia/GitHub/BetaML.jl")))

using BetaML      
using Plots  

xtrain = [
    "Green"  3.0;
    "Yellow" 3.0;
    "Red"    1.0;
    "Red"    1.0;
    "Yellow" 3.0;
]
ytrain = ["Apple",  "Apple", "Grape", "Grape", "Lemon"]

myTree = buildTree(xtrain,ytrain)

feature_names = ["Intensity", "Color"]

wtree = BetaML.wrap(myTree, (featurenames = feature_names, ))

