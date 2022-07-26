"""
A plot recipe (based on `RecipeBase.jl`) to create a graphical representation of a decision tree.

The decision tree must be wrapped in an `AbstractTrees`-interface (see `DecisionTree.jl` as 
an example implementation of the concept). This approach ensures that the recipe is independent of the
implementation details of the decision tree.
"""
module DecisionTreesRecipe

include("AbstractInfoTree.jl")

import AbstractTrees
using NetworkLayout
using Graphs
using RecipesBase

export AbstractInfoNode, AbstractInfoLeaf

"""
# Overview

The recipe uses the Buchheim-Algorithm (from `NetworkLayout.jl`) to generate a layout for the decision tree. 
As this algorithm requires a `SimpleDiGraph` (from `Graphs.jl`) as its input, the tree has to be converted
first into that structure. For that purpose the nodes of the tree have to be numbered from 1 to `n` 
(`n` being the number of nodes in the tree) in a breadth first order (as the edges of a `SimpleDiGraph` 
are specified by pairs of such numbers).

So the recipe applies the following steps to convert a decision tree into a graphical representation:

1. Flatten
   The tree is converted in a breadth first order into a list (a `Vector`) of `NodeInfo`s. 
   These elements contain the relevant information for visualizing the tree lateron. The indices
   within this array correspond to the above required numbers from 1 to `n` (1 is the root node).
   The functions `flatten` and `add_level!` implement this step. 

2. Generate layout
   The (number) information from the flat structure is taken to create a corresponding `SimpleDiGraph`.
   Using the Buchheim-algorithm on this graph, a layout (consisting of the coordinates of the nodes)
   is generated. This step is implemented by `layout`.

3. Make a visual description (using a plot recipe)
   The plot recipe `dt_visualization` creates a visual description of the tree using the information of 
   the two preceding steps.
"""

### Step 1: Flatten

# plotting information for each node/leaf of the tree
struct PlotInfo
    parent_id   :: Int16        # number of the parent node within the tree
    is_leaf     :: Bool         # is the node a leaf?
    print_label :: String       # text to be printed as a label in the visualization of the node 
end

"""
    add_level!(plot_infos::Vector{PlotInfo}, nodes, i_crnt)

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

# extract and format label information from nodes/leaves
function label(i::Union{<:AbstractInfoNode, <:AbstractInfoLeaf})
    io = IOBuffer()
    AbstractTrees.printnode(io, i)
    return(String(take!(io)))
end

# which type of node is it?
is_leaf(i::AbstractInfoNode) = false
is_leaf(i::AbstractInfoLeaf) = true

"""
    flatten(tree::InfoNode)

Create a list of all nodes/leaves (converted to `PlotInfo`s) within the `tree` in a breadth first order.
"""
function flatten(tree::AbstractInfoNode)
    plot_infos = Vector{PlotInfo}(undef, AbstractTrees.treesize(tree))          # tree has `treesize` nodes 
    plot_infos[1] = PlotInfo(-1, false, label(tree))                            # root node is first entry; -1 is a dummy 
    add_level!(plot_infos, [tree], 1)                                           # add recursevly nodes of all further tree levels to the list 
    return(plot_infos)
end


### Step 2: Generate layout

"""
    layout()

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
Rectangular shape with centerpoint `center` and dimensions `width` and `height`
"""
function make_rect(center, width, height)
    left, right  = center[1] - width/2.0,  center[1] + width/2.0
    upper, lower = center[2] + height/2.0, center[2] - height/2.0
    return([(left, upper), (right, upper), (right, lower), (left, lower), (left, upper)])
end

"""
Linear curve starting at the `parent`s bottom center leading to the `child`s top center.
`parent` and `child` are the center coordinates of the respective nodes.
"""
function make_line(parent, child, height)
    parent_xbottom, parent_ybottom = parent[1], parent[2] - height/2
    child_xtop,     child_ytop     = child[1],  child[2]  + height/2
    return([parent_xbottom, child_xtop], [parent_ybottom, child_ytop])
end

"""
    dt_visualization(tree::InfoNode)

Graph recipe to draw a decsion tree (wrapped in an `AbstractTree`)
"""
@recipe function dt_visualization(tree::AbstractInfoNode, width = 0.7, height = 0.7)
    # prepare data 
    plot_infos = flatten(tree)
    coords = layout(plot_infos)

    # we paint on a blank paper
    framestyle --> :none
    legend --> false
    
    # connecting lines are a series of curves 
    for i in 2:length(plot_infos) 
        @series begin
            seriestype := :curves
            linecolor --> :silver 
            line = make_line(coords[plot_infos[i].parent_id], coords[i], height)
            return line
        end
    end

    # nodes are a series of rectangular shapes
    anns = plotattributes[:annotations] = []        # for the labels within the rectangles
    for i in eachindex(coords)
        @series begin
            seriestype := :shape
            fillcolor --> :deepskyblue3
            alpha --> (plot_infos[i].is_leaf ? 0.4 : 0.15)
            annotationcolor --> :brown4
            annotationfontsize --> 7
            c = coords[i]
            push!(anns, (c[1], c[2], (plot_infos[i].print_label,)))
            return make_rect(c, width, height)
        end
    end
end


end # module
