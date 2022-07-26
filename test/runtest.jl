using Pkg
Pkg.develop(PackageSpec(path = ("/Users/roland/Library/CloudStorage/OneDrive-adviionGmbH/__Projekte/Julia/GitHub/DecisionTree.jl")))

using DecisionTree      
using Plots  

"""
Create some test tree
"""
feature_names = ["feat1", "feat2", "feat3", "feat4"]
class_labels = ["a", "b", "c"]

function make_dtree()
    l1 = Leaf(1, [1,1,2])
    l2 = Leaf(2, [1,2,2])
    l3 = Leaf(3, [3,3,1])
    l4 = Leaf(1, [1,1,1])
    l5 = Leaf(2, [2,2,2])
    n4 = Node(4, 0.8, l4, l5)
    n3 = Node(3, 0.3, n4, l3)
    n2 = Node(2, 0.5, l1, l2)
    n1 = Node(1, 0.7, n2, n3)
    return(n1)
end

dt = make_dtree()
infotree = DecisionTree.wrap(dt, (featurenames = feature_names, classlabels = class_labels))