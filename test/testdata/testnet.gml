graph [
        comment "This is a sample graph"
        directed 1
        label "Hello, I am a graph"
        node [
                id 1
                label "node 1"
                size 23
        ]
        node [
                id 2
                label "node 2"
        ]
        node [
                id 3
                label "node 3"
                size 44
        ]
        edge [
                source 1
                target 2
                label "Edge from node 1 to node 2"
                weight 2.1
        ]
        edge [
                source 2
                target 3
                label "Edge from node 2 to node 3"
                weight 1.4
        ]
        edge [
                source 3
                target 1
                label "Edge from node 3 to node 1"
                weight 9.1
        ]
]
