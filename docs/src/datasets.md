# Graphs Datasets
The [datasets folder](https://github.com/CarloLucibello/Erdos.jl/tree/master/datasets)
contains real world graphs in the graph-tool format `.gt`, mostly
collected by Tiago de Paula Peixoto. They are released under the GPLv3 license,

They can be read with
```julia
readgraph(s, G=Graph)
```
where `s` is any of the symbols below and `G` is a (di)graph type.
Here is a complete list of the graphs in the form

 s        |      N        |    E         |   directed |
....description....

---------------------------------------------------

:adjnoun        |      112    |      425    |      false |    
 Word adjacencies: adjacency network of common  adjectives and nouns in the novel David Copperfield by Charles Dickens. Please cite M. E. J. Newman, Phys. Rev. E 74, 036104 (2006). Retrieved from [Mark Newman's website](http://www-personal.umich.edu/~mejn/netdata/).

:as22july06     |     22963   |     48436   |     false  |   
Internet: a symmetrized snapshot of the structure of the Internet at the level of autonomous systems, reconstructed from BGP tables posted by the [University of Oregon Route Views Project](http://routeviews.org/). This snapshot was created by Mark Newman from data for July 22, 2006 and is not previously published. Retrieved from [Mark Newman's website]( http://www-personal.umich.edu/~mejn/netdata/).

:astroph        |     16706   |     121251  |     false  |   
Astrophysics collaborations: weighted network of coauthorships between scientists posting preprints on the Astrophysics E-Print Archive between Jan 1, 1995 and December 31, 1999. Please cite M. E. J. Newman, Proc. Natl. Acad. Sci. USA 98, 404-409 (2001). Retrieved from [Mark Newman's website](http://www-personal.umich.edu/~mejn/netdata/).

:celegansneural |      297    |      2359   |      true  |    
Neural network: A directed, weighted network representing the neural network of C. Elegans. Data compiled by D. Watts and S. Strogatz and made available on the web [here](http://cdg.columbia.edu/cdg/datasets). Please cite D. J. Watts and S. H. Strogatz, Nature 393, 440-442 (1998). Original experimental data taken from J. G. White, E. Southgate, J. N. Thompson, and S. Brenner, Phil. Trans. R. Soc. London 314, 1-340 (1986). Retrieved from [Mark Newman's website](http://www-personal.umich.edu/~mejn/netdata/)

:condmat        |     16726   |     47594   |     false  |   
Condensed matter collaborations 1999: weighted network of coauthorships between scientists posting preprints on the Condensed Matter E-Print Archive between Jan 1, 1995 and December 31, 1999. Please cite M. E. J. Newman, The structure of scientific collaboration networks, Proc. Natl. Acad. Sci. USA 98, 404-409 (2001). Retrieved from [Mark Newman's website](http://www-personal.umich.edu/~mejn/netdata/)

:condmat2003    |    31163    |    120029   |    false   |  
Condensed matter collaborations 2003: updated network of coauthorships between scientists posting preprints on the Condensed Matter E-Print Archive. This version includes all preprints posted between Jan 1, 1995 and June 30, 2003. The largest component of this network, which contains 27519 scientists, has been used by several authors as a test-bed for community-finding algorithms for large networks; see for example J. Duch and A. Arenas, Phys. Rev. E 72, 027104 (2005). These data can be cited as M. E. J. Newman, Proc. Natl. Acad. Sci. USA 98, 404-409 (2001). Retrieved from [Mark Newman's website](http://www-personal.umich.edu/~mejn/netdata/).

:condmat2005    |    40421    |    175693   |    false   |  
Condensed matter collaborations 2005: updated network of coauthorships between scientists posting preprints on the Condensed Matter E-Print Archive. This version includes all preprints posted between Jan 1, 1995 and March 31, 2005. Please cite M. E. J. Newman, Proc. Natl. Acad. Sci. USA 98, 404-409 (2001). Retrieved from [Mark Newman's website](http://www-personal.umich.edu/~mejn/netdata/).

:dolphins       |      62     |      159    |      false |   
Dolphin social network: an undirected social network of frequent associations between 62 dolphins in a community living off Doubtful Sound, New Zealand. Please cite D. Lusseau, K. Schneider, O. J. Boisseau, P. Haase, E. Slooten, and S. M. Dawson, Behavioral Ecology and Sociobiology 54, 396-405 (2003). Retrieved from [Mark Newman's website](http://www-personal.umich.edu/~mejn/netdata/).

:emailenron     |     36692   |     183831  |     false  |   
Enron email communication network covers all the email communication within a dataset of around half million emails. This data was originally made public, and posted to the web, by the Federal Energy Regulatory Commission during its investigation. Nodes of the network are email addresses and if an address i sent at least one email to address j, the graph contains an undirected edge from i to j. Note that non-Enron email addresses act as sinks and sources in the network as we only observe their communication with the Enron email addresses. The Enron email data was [originally released]( http://www.cs.cmu.edu/~enron/) by William Cohen at CMU. This version was retrieved from the SNAP database at http://snap.stanford.edu/data/email-Enron.html. Please cite: J. Leskovec, K. Lang, A. Dasgupta, M. Mahoney. Community Structure in Large Networks: Natural Cluster Sizes and the Absence of Large Well-Defined Clusters. Internet Mathematics 6(1) 29--123, 2009,  B. Klimmt, Y. Yang. Introducing the Enron corpus. CEAS conference, 2004.

:football       |      115    |      615    |      false |    
American College football: network of American football games between Division IA colleges during regular season Fall 2000. Please cite M. Girvan and M. E. J. Newman, Proc. Natl. Acad. Sci. USA 99, 7821-7826 (2002), and T.S. Evans, "Clique Graphs and Overlapping Communities", J.Stat.Mech. (2010) P12037 [arXiv:1009.0638]. Retrieved from [Mark Newman's website]( http://www-personal.umich.edu/~mejn/netdata/), with corrections by T. S. Evans, available [here](http://figshare.com/articles/American_College_Football_Network_Files/93179).

:hepth          |     8361    |     15751   |     false  |   
High-energy theory collaborations: weighted network of coauthorships between scientists posting preprints on the High-Energy Theory E-Print Archive between Jan 1, 1995 and December 31, 1999. Please cite M. E. J. Newman, Proc. Natl. Acad. Sci. USA 98, 404-409 (2001). Retrieved from [Mark Newman's website](http://www-personal.umich.edu/~mejn/netdata/).

:karate         |      34     |      78     |      false |    
Zachary's karate club: social network of friendships between 34 members of a karate club at a US university in the 1970s. Please cite W. W. Zachary, An information flow model for conflict and fission in small groups, Journal of Anthropological Research 33, 452-473 (1977). Retrieved from [Mark Newman's website](http://www-personal.umich.edu/~mejn/netdata/).

:lesmis         |      77     |      254    |      false |    
Les Miserables: coappearance network of characters in the novel Les Miserables. Please cite D. E. Knuth, The Stanford GraphBase: A Platform for Combinatorial Computing, Addison-Wesley, Reading, MA (1993). Retrieved from [Mark Newman's website](http://www-personal.umich.edu/~mejn/netdata/).

:netscience     |      1589   |      2742   |      false |    
Coauthorships in network science: coauthorship network of scientists working on network theory and experiment, as compiled by M. Newman in May 2006. A figure depicting the largest component of this network can be found [here](http://www-personal.umich.edu/~mejn/centrality/). These data can be cited as M. E. J. Newman, Phys. Rev. E 74, 036104 (2006). Retrieved from [Mark Newman's website](http://www-personal.umich.edu/~mejn/netdata/).

:pgpstrong2009  |    39796    |    301498   |    true    |
Strongly connected component of the PGP web of trust circa November 2009. The full data is available at http://key-server.de/dump/. Please cite: Richters O, Peixoto TP (2011) Trust Transitivity in Social Networks. PLoS ONE 6(4): e18384. :doi:`10.1371/journal.pone.0018384`.

:polblogs       |      1490   |      19090  |      true  |    
Political blogs: A directed network of hyperlinks between weblogs on US politics, recorded in 2005 by Adamic and Glance. Please cite L. A. Adamic and N. Glance, "The political blogosphere and the 2004 US Election", in Proceedings of the WWW-2005 Workshop on the Weblogging Ecosystem (2005). Retrieved from [Mark Newman's website](http://www-personal.umich.edu/~mejn/netdata/).

:polbooks       |      105    |      441    |      false |    
Books about US politics: A network of books about US politics published around the time of the 2004 presidential election and sold by the online bookseller Amazon.com. Edges between books represent frequent copurchasing of books by the same buyers. The network was compiled by V. Krebs and is unpublished, but can found on Krebs' [web site](http://www.orgnet.com/). Retrieved from [Mark Newman's website](http://www-personal.umich.edu/~mejn/netdata/).

:power          |      4941   |      6594   |      false |   
 Power grid: An undirected, unweighted network representing the topology of the Western States Power Grid of the United States. Data compiled by D. Watts and S. Strogatz and made available on the web [here](http://cdg.columbia.edu/cdg/datasets). Please cite D. J. Watts and S. H. Strogatz, Nature 393, 440-442 (1998). Retrieved from [Mark Newman's website](http://www-personal.umich.edu/~mejn/netdata/).

:serengetifoodweb |   161     |     592     |     true   |   
Plant and mammal food web from the Serengeti savanna ecosystem in Tanzania. Please cite: Baskerville EB, Dobson AP, Bedford T, Allesina S, Anderson TM, et al. (2011) Spatial Guilds in the Serengeti Food Web Revealed by a Bayesian :doi:`10.1371/journal.pcbi.1002321` Group Model. PLoS Comput Biol 7(12): e1002321
