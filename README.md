Source Codes and Data for:

**SPATIAL MEMORY OBVIATES FOLLOWING BEHAVIOR IN AN INFORMATION CENTER OF WILD FRUIT BATS**

**Overview**

These are the source codes for the manuscript which tests for the _information center hypotheses_ in roosts and around foraging trees for wild Egyptian fruit bats (_Rousettus aegyptiacus_) in the Hula Valley, Israel. 
The code for all analyses can be found under the main branch and described below for each of the two analyses. 
There are two codes, one for each analysis described hereunder. Both are .Rmd files. 

renv/

Settings to restore the R packages to the versions used in this project.

src/

Two helper function for the second analysis (tree encounters) only: One for calculating distances
between points, and the second includes three function that are used to derive the tree visitation patters of bats that met on trees, following encounters on trees. 

data/

The folder contains all source-data (bats tree visits, and individual measurements), and an additional folder for the outputs created while running the code of the tree-encounter analysis (tree_encounters). Description of the relevant data-tables per analysis are provided below. The data folder also contains two additional .word files that describe the columns of the two main datasets of bats’ tree visit that were analyzed, i.e., all_tree_visits_main.csv & data_information_trees_main.csv. 

**(1) Analysis of Information transfer in cave-roosts, based on field manipulations**

Script: Ficus_Sycamorus_Experiment.Rmd**

•	This code begins with reading the tree-visit data of all bats - all_tree_visits_main.csv; and the table containing the results of the field manipulation for the information transfer in cave-roost (Field_Manipulation_Table.csv) where we counted the number of bats that visited, and that did not visit, the _F. sycomorus_ trees after the manipulation.

•	The tree visitation table, termed “all_stops” in the code (as in tree stops, and not commute) are derived from an extensive procedure of filtering, segmenting, and appending the relevant tree attributes from raw ATLAS tracks of bats and an exahstive tree loation and species dataset. More information about this procedure can be found at Gupte, P. R., Beardsworth, C. E., Spiegel, O., Lourie, E., Toledo, S., Nathan, R., & Bijleveld, A. I. (2022). A guide to pre‐processing high‐throughput animal tracking data. Journal of Animal Ecology, 91(2), 287-307. 

•	At the end, the code compares the probability of bats to visit one of the two _F. sycomorus_ trees in the landscape, derived from the stops data, during times were the trees provided no fruits. It then compares and test the differences in the probabilities of bats visiting the trees 1 to 6 nights after the manipulation, against the proportion of (other) bats visiting these tees durig routine movment for the same time frames, when the trees bore no fruits (sampled at random, without replacement). 

•	Note: there are differences between the tree-visit data that are used for the two analyses. Here, the motivation was to use the maximal number of “stops,” including short ones (<1 min) and the ones of bats that were tracked briefly (< 3 nights). As such, we aimed to ensure the probabilities to visit F. sycomorus during routine movements are maximized, making the comparison against the manipulation highly conservative since in reality there were probably less visits to the target trees than counted here.  

**(1) Analysis of Information transfer on trees** 

Script: Sharing_Information_Trees.Rmd

•	This code begins with reading the tree-visit data of all bats - data_information_trees_main.csv, and creates a “pseudo following” tables that describe whether bats that met on trees at the same time (i.e., encountered), proceeded to visit each other’s’ trees after they met (results per night after the meeting are saved while running the code in the tree_encounters folder). 

Note: Here, the tree-stops dataset is smaller than in the previous analysis, since we wanted (1) to make sure all the bats included in the analysis had ample time to learn from each other, so we only included bats that were tracked > 3 nights. 

•	Individual bats’ measurements were added (nd_info.csv) to remove pups that may be attached to their mothers. 

•	Three helper functions are included within the "src/PsuedoFunction.R" code, which adds a column of instances when a bat visits a new patch of trees (so to ask if a new tree visit was of an unknown tree), the main tree-encounter analysis that creates a table with pairs of bats and documents whether they visited each other’s trees or not, and in what order. And lastly, a function that reads the results of the tree-encounter analysis of each night (from the night they met up until 6 nights after), to summarize it into a table for running the model comparing the probabilities to visit each other’s trees for dyads that met, and dyads that did not. The code ends with the creation of Fig. 3. 

