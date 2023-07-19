"""
A plot recipe (based on `RecipeBase.jl`) to create a graphical representation of a tree.
The recipe has originally been designed to plot decision trees, but it is able to plot all sort
of trees which conform to the following rules.

The tree must be wrapped in an `AbstractTrees`-interface (see `DecisionTree.jl` as 
an example implementation of the concept). I.e. it has
- to be a subtype of `AbstractTrees.AbstractNode{T}`
- implement `AbstractTrees.children()`
- implement `AbstractTrees.printnode()`

This approach ensures that the recipe is independent of the implementation details of the tree.
"""
module TreeRecipe

import AbstractTrees
using NetworkLayout
using Graphs
using RecipesBase


"""
# Overview

The recipe uses the Buchheim-Algorithm (from `NetworkLayout.jl`) to generate a layout for the tree. 
As this algorithm requires a `SimpleDiGraph` (from `Graphs.jl`) as its input, the tree has to be converted
first into that structure. For that purpose the nodes of the tree have to be numbered from 1 to `n` 
(`n` being the number of nodes in the tree) in a breadth first order (as the edges of a `SimpleDiGraph` 
are specified by pairs of such numbers).

So the recipe applies the following steps to convert a tree into a graphical representation:

1. Flatten
   The tree is converted in a breadth first order into a list (a `Vector`) of `PlotInfo`s. 
   These elements contain the relevant information for visualizing the tree later on. The indices
   within this array correspond to the above required numbers from 1 to `n` (1 is the root node).
   The functions `flatten` and `add_level!` implement this step. 

2. Generate layout
   The information from the flat structure (numbering) is taken to create a corresponding `SimpleDiGraph`.
   Using the Buchheim-algorithm on this graph, a layout (consisting of the coordinates of the tree nodes)
   is generated. This step is implemented by `layout`.

3. Make a visual description (using a plot recipe)
   The plot recipe `tree_visualization` creates a visual description of the tree using the information of 
   the two preceding steps.
"""

### Step 1: Flatten

# plotting information (which is generated) for each node/leaf of the tree
struct PlotInfo
    parent_id   :: Int32        # number of the parent node within the tree
    is_leaf     :: Bool         # is the node a leaf?
    print_label :: String       # text to be printed as a label in the visualization of the node 
end

"""
    add_level!(plot_infos::Vector{PlotInfo}, nodes::Vector{AbstractNode}, i_crnt::Integer)

Traverse the tree recursively beginning from the root, level by level, collecting on each level
all nodes from left to right and adding them to the `plot_infos`-list in form of `PlotInfo`s.

On each call, a `Vector` of nodes from the last level processed is given in `nodes`. So on the first 
call a one-element array containing the root node is passed. `i_crnt` is the index of the 
`PlotInfo`-element in `plot_infos` corresponding to the first node in `nodes`. 

On the first call, `add_level!` expects the first entry in `plot_infos` for the root node already 
to be present (so this has to be done manually).
"""
function add_level!(plot_infos::Vector{PlotInfo}, nodes, i_crnt)
    i_next = i_crnt + length(nodes) 
    child_nodes = []    
    for n in nodes
        cn = AbstractTrees.children(n)
        for c in cn
            plot_infos[i_next]  = PlotInfo(i_crnt, is_leaf(c), label(c))
            push!(child_nodes, c)
            i_next += 1
        end
        i_crnt += 1
    end
    if length(child_nodes) > 0
        add_level!(plot_infos, child_nodes, i_crnt)
    end
end

"extract label information from nodes/leaves using `printnode`"
function label(i::AbstractTrees.AbstractNode)
    io = IOBuffer()
    AbstractTrees.printnode(io, i)
    return(String(take!(io)))
end

"Is the node a leaf or a (inner) node?"
is_leaf(i::AbstractTrees.AbstractNode) = isempty(AbstractTrees.children(i))

"""
    flatten(tree::AbstractTrees.AbstractNode))

Create a list of all nodes/leaves (converted to `PlotInfo`s) within the `tree` in a breadth first order.
"""
function flatten(tree::AbstractTrees.AbstractNode)
    plot_infos = Vector{PlotInfo}(undef, AbstractTrees.treesize(tree))          # tree has `treesize` nodes 
    plot_infos[1] = PlotInfo(-1, false, label(tree))                            # root node is first entry; -1 is a dummy 
    add_level!(plot_infos, [tree], 1)                                           # add recursevly nodes of all further tree levels to the list 
    return(plot_infos)
end


### Step 2: Generate layout

"""
    layout(plot_infos::Vector{PlotInfo})

Create a tree layout in form of a list of points (`GeometryBasics.Point2`) based on the list of
`PlotInfo`s created by `flatten`. The order of the points in the list corresponds to the information in 
the `plot_infos`-list passed. 
"""
function layout(plot_infos::Vector{PlotInfo})
    g = SimpleDiGraph(length(plot_infos))
    for i in 2:length(plot_infos)
        add_edge!(g, plot_infos[i].parent_id, i)
    end
    return(buchheim(g))
end


### Step 3: Make a visual description (using a plot recipe)

"""
    make_rect(center::Point, width::Number, height::Number)

Corner points of a rectangular shape with centerpoint `center` and dimensions `width` and `height`
"""
function make_rect(center, width, height)
    left, right  = center[1] - width/2.0,  center[1] + width/2.0    # x-coordinates
    upper, lower = center[2] + height/2.0, center[2] - height/2.0   # y-coordinates
    return([(left, upper), (right, upper), (right, lower), (left, lower), (left, upper)])
end

"""
    make_line(parent::Point, child::Point, height::Number)

Line starting at the `parent`s bottom center leading to the `child`s top center.
`parent` and `child` are the center coordinates of the respective nodes (rectangles).
`height` is their height.
"""
function make_line(parent, child, height)
    parent_xbottom, parent_ybottom = parent[1], parent[2] - height/2
    child_xtop,     child_ytop     = child[1],  child[2]  + height/2
    return([parent_xbottom, child_xtop], [parent_ybottom, child_ytop])
end

"""
    tree_visualization(tree::AbstractNode, width = 0.7, height = 0.7)

Plot recipe to convert a tree (wrapped in an `AbstractNode`) into a graphical representation

Note: As it isn't possible to calculate the size of the bounding box of the label which is
printed inside each node rectangle, the default values for `width` and `height` of these 
rectangles are just a 'good guess'. You may have to adapt them when calling the recipe.
"""
@recipe function tree_visualization(tree::AbstractTrees.AbstractNode, width = 0.7, height = 0.7)
    # prepare data 
    plot_infos = flatten(tree)
    coords = layout(plot_infos)

    # we paint on a blank paper
    framestyle --> :none
    legend --> false
    
    # connecting lines are a series of linear `:curves`
    for i in 2:length(plot_infos) 
        @series begin
            seriestype := :curves
            linecolor --> :silver 
            line = make_line(coords[plot_infos[i].parent_id], coords[i], height)
            return line
        end
    end

    # nodes are a series of rectangular `:shapes`
    anns = plotattributes[:annotations] = []        # for the labels within the rectangles
    for i in eachindex(coords)
        @series begin
            seriestype := :shape
            fillcolor --> :deepskyblue3
            alpha --> (plot_infos[i].is_leaf ? 0.4 : 0.15)  # plot leaves a bit darker than inner nodes
            annotationcolor --> :brown4
            annotationfontsize --> 7
            c = coords[i]
            push!(anns, (c[1], c[2], (plot_infos[i].print_label,)))
            return make_rect(c, width, height)
        end
    end
end


end # module
