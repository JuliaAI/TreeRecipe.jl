"""
The `DecisionTree`-package is used an example on how to implement the necessary ad-ons 
in order to make it plottable using the `TreeRecipe`. The following code shows how the
recipe can be applied to a `DecisionTree` and it is used as a test for the plot recipe.

The first test ("visual test") just plots the decsion tree `dt` and is thus a purely 
visual test.

The second test ("structural test") checks, if the tree layout that has been created
by the Buchheim algorithm represents geometrically the structrure of decision tree `dt`.
"""

using DecisionTree      
using Plots  
using TreeRecipe
using Test

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

# add information about feature names and class names
wt = DecisionTree.wrap(dt, (featurenames = feature_names, classlabels = class_labels))

@testset "visual test" begin
    # plot the tree using the `TreeRecipe`
    # this is a rather visual test, to see, if the tree gets plotted correctly
    plot(wt; connect_labels = ["yes", "no"])    # this calls automatically the `TreeRecipe`
end

@testset "structural test" begin
    # this test checks, if the coordinates of the tree layout have the same
    # structrure as the tree created by `make_dtree()``

    # some helper functions
    is_left_of(p1, p2) = p1[1] < p2[1]      # is point `p1` left of `p2`?
    is_above(p1, p2) = p1[2] > p2[2]        # is point `p1` above `p2`?

    # corresponds the order of the points in `plist` to their geometric horizontal order?
    is_horizontally_ordered(plist) = sum(map(is_left_of, plist[1:end-1], plist[2:end])) == length(plist)-1

    # is point `p` (geometrically) above all the points in `plist`?
    is_above_all(p, plist) = sum(map(other -> is_above(p, other), plist)) == length(plist)

    # create the layout of tree `wt`
    @info("-- create layout of tree")
    plotinfo = TreeRecipe.flatten(wt)
    coords = TreeRecipe.layout(plotinfo)    # `coords` is a list of points; each point represents a node in the tree

    # extract the different tree levels
    @info("-- extract tree levels")
    root = coords[1]
    level1 = coords[2:3]
    level2 = coords[4:7]
    level3 = coords[8:9]

    # check their structural correctnes
    @info("-- check layout structure")
    @test is_above_all(root, level1)
    @test is_horizontally_ordered(level1)
    @test is_horizontally_ordered(level2)
    @test is_horizontally_ordered(level3)
    @test sum(map(p -> is_above_all(p, level2), level1)) == length(level1)
    @test sum(map(p -> is_above_all(p, level3), level2)) == length(level2)
end


