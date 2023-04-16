## The Graph interface represents a graph using an adjacency list and exposes
## functions for working with graphs, such as creating one from a list and
## performing a depth-first or breadth-first search.
interface Graph
    exposes [
        Graph,
        fromList,
        fromDict,
        dfs,
        bfs,
    ]
    imports []

## Graph type representing a graph as a dictionary of adjacency lists
## where each key is a vertex and each value is a list of its adjacent vertices.
Graph a := Dict a (List a) | a has Eq

## Create a Graph from an adjacency list.
fromList : List (a, List a) -> Graph a
fromList = \adjacencyList ->
    emptyDict = Dict.withCapacity (List.len adjacencyList)

    update = \dict, (vertex, edges) ->
        Dict.insert dict vertex edges

    List.walk adjacencyList emptyDict update
    |> @Graph

## Create a Graph from an adjacency list.
fromDict : Dict a (List a) -> Graph a
fromDict = @Graph

## Perform a depth-first search on a graph to find a target vertex.
##
## - `isTarget` : A function that returns true if a vertex is the target.
## - `root`     : The starting vertex for the search.
## - `graph`    : The graph to perform the search on.
dfs : (a -> Bool), a, Graph a -> Result a [NotFound]
dfs = \isTarget, root, @Graph graph ->
    dfsHelper isTarget [root] (Set.empty {}) graph

# A helper function for performing the depth-first search.
#
# `isTarget` : A function that returns true if a vertex is the target.
# `stack`    : A List of vertices to visit.
# `visited`  : A Sist of visited vertices.
# `graph`    : The graph to perform the search on.
dfsHelper : (a -> Bool), List a, Set a, Dict a (List a) -> Result a [NotFound]
dfsHelper = \isTarget, stack, visited, graph ->
    when stack is
        [] ->
            Err NotFound

        [.., current] ->
            rest = List.dropLast stack

            if isTarget current then
                Ok current
            else if Set.contains visited current then
                dfsHelper isTarget rest visited graph
            else
                newVisited = Set.insert visited current

                when Dict.get graph current is
                    Ok neighbors ->
                        # filter out all seen neighbors
                        filtered = List.keepIf neighbors (\n -> !(Set.contains visited n))

                        # newly explored nodes are added to LIFO stack
                        newStack = List.concat rest filtered

                        dfsHelper isTarget newStack newVisited graph

                    Err KeyNotFound ->
                        dfsHelper isTarget rest newVisited graph

## Perform a breadth-first search on a graph to find a target vertex.
##
## - `isTarget` : A function that returns true if a vertex is the target.
## - `root`     : The starting vertex for the search.
## - `graph`    : The graph to perform the search on.
bfs : (a -> Bool), a, Graph a -> Result a [NotFound]
bfs = \isTarget, root, @Graph graph ->
    bfsHelper isTarget [root] (Set.empty {}) graph

# A helper function for performing the breadth-first search.
#
# `isTarget` : A function that returns true if a vertex is the target.
# `queue`    : A List of vertices to visit.
# `visited`  : A Set of visited vertices.
# `graph`    : The graph to perform the search on.
bfsHelper : (a -> Bool), List a, Set a, Dict a (List a) -> Result a [NotFound]
bfsHelper = \isTarget, queue, visited, graph ->
    when queue is
        [] ->
            Err NotFound

        [current, ..] ->
            rest = List.dropFirst queue

            if isTarget current then
                Ok current
            else if Set.contains visited current then
                bfsHelper isTarget rest visited graph
            else
                newVisited = Set.insert visited current

                when Dict.get graph current is
                    Ok neighbors ->
                        # filter out all seen neighbors
                        filtered = List.keepIf neighbors (\n -> !(Set.contains visited n))

                        # newly explored nodes are added to the FIFO queue
                        newQueue = List.concat rest filtered

                        bfsHelper isTarget newQueue newVisited graph

                    Err KeyNotFound ->
                        bfsHelper isTarget rest newVisited graph

# Test using depth-first search.
expect
    actual = dfs (\v -> v == "F") "A" testGraphSmall
    expected = Ok "F"

    actual == expected

## Test and breadth-first search.
expect
    actual = bfs (\v -> v == "F") "A" testGraphSmall
    expected = Ok "F"

    actual == expected

# Test node not present depth-first search
expect
    actual = dfs (\v -> v == "X") "A" testGraphSmall
    expected = Err NotFound

    actual == expected

# Test node not present breadth-first search
expect
    actual = dfs (\v -> v == "X") "A" testGraphSmall
    expected = Err NotFound

    actual == expected

# Test using depth-first search large.
expect
    actual = dfs (\v -> v == "AE") "A" testGraphLarge
    expected = Ok "AE"

    actual == expected

## Test and breadth-first search large.
expect
    actual = bfs (\v -> v == "AE") "A" testGraphLarge
    expected = Ok "AE"

    actual == expected

# Some helpers for testing
testGraphSmall =
    [
        ("A", ["B", "C"]),
        ("B", ["D", "E"]),
        ("C", []),
        ("D", []),
        ("E", ["F"]),
        ("F", []),
    ]
    |> fromList

testGraphLarge =
    [
        ("A", ["B", "C", "D"]),
        ("B", ["E", "F", "G"]),
        ("C", ["H", "I", "J"]),
        ("D", ["K", "L", "M"]),
        ("E", ["N", "O"]),
        ("F", ["P", "Q"]),
        ("G", ["R", "S"]),
        ("H", ["T", "U"]),
        ("I", ["V", "W"]),
        ("J", ["X", "Y"]),
        ("K", ["Z", "AA"]),
        ("L", ["AB", "AC"]),
        ("M", ["AD", "AE"]),
        ("N", []),
        ("O", []),
        ("P", []),
        ("Q", []),
        ("R", []),
        ("S", []),
        ("T", []),
        ("U", []),
        ("V", []),
        ("W", []),
        ("X", []),
        ("Y", []),
        ("Z", []),
        ("AA", []),
        ("AB", []),
        ("AC", []),
        ("AD", []),
        ("AE", []),
    ]
    |> fromList
