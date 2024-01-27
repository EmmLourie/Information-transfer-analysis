# Functions for information transfer on tree analysis: (1) add information when a bat visited a new tree (add_new_trees) and (2) create a table where it identifies bats that met and whether one bat (A) visited new trees that the other bat (B) already visited. 
# It is called "pseudo following", becasue they probably didn't follow each other en-route, but rather learned about it existence and visited it later (as though they were following). 

add_new_trees<-function(data_no_caves, cluster="Tree"){
  Tag_list<-unique(data_no_caves$TAG)
  data_acc<-NULL
  for (t in 1:length(Tag_list)){
    TAG <- data_no_caves[which(data_no_caves$TAG==Tag_list[t]),]
    TAG <- TAG[order(TAG$start),]
    if(cluster=="patch"){
      TAG$new_p<-cumsum(!duplicated(TAG$patch))
      if (nrow(TAG)>1){
        TAG$new_diff_patch<-c(0, diff(TAG$new_p))
        TAG<-TAG %>% arrange(start)
        data_acc<-rbind(data_acc,TAG)
      } else { print(paste0("No data of tag=",Tag_list[t]))}
    }else{
      TAG$new_t<-cumsum(!duplicated(TAG$cluster_Tree))
      if (nrow(TAG)>1){
        TAG$new_diff<-c(0, diff(TAG$new_t))
        TAG<-TAG %>% arrange(start)
        TAG$dist<-pt.dist(TAG$medX, TAG$medY)
        TAG$new_diff<-ifelse(TAG$dist<50,0, TAG$new_diff) # if the trees are close (<50m), don't count it as a new tree (could be "on the way")
        data_acc<-rbind(data_acc,TAG)
      } else { print(paste0("No data of tag=",Tag_list[t]))}
    }}
  return(data_acc)
}



FindFollowPast <- function(n,overlaps_tags,dt_stops,n_nights=4, tree_type="pred"){
  library(data.table)
  library(tidyverse)
  unpred_speceis<-c("Palm","Carob", "Ficus religiosa" ,"Ficus sycomorus","Ficus","Ficus microcarpa")
  IndA<-overlaps_tags$TAGA[n]
  IndB<-overlaps_tags$TAGB[n]
  #IndA<-"5022"
  #IndB<-"5013"
  OneInd<-dt_stops[dt_stops$TAG==IndA,]
  SecondInd<-dt_stops[dt_stops$TAG==IndB,]
  TwoInds<-rbind(OneInd,SecondInd)
  
  treesA<-unique(OneInd$cluster_Tree)
  treesB<-unique(SecondInd$cluster_Tree)

  shared_trees_all<-intersect(treesA,treesB)
  if(length(shared_trees_all)==0){
    tree_met<-"None"
    date_met<-NA
    n_shared_trees<-0;prop_shared_A_future<-0;propA_first<-0;propA_first_all<-0;nights_min<-NA
    ;n_shared_new_trees<-0;n_future_trees_A<-0; trees_species_A_future<-0
  }else{
    
    # were they there in the same time?
    cols<-c("date_global","TAG","Night","TAG_Night","month","fruit_season", "cluster_Tree","X_tree","Y_tree","start" , "end", "time_start","time_end")
    
    IndA_dt<-data.table(OneInd[OneInd$cluster_Tree %in% shared_trees_all,cols])
    IndB_dt<-data.table(SecondInd[SecondInd$cluster_Tree %in% shared_trees_all, cols], key=c("cluster_Tree","start", "end"))
    
    overlaps<-foverlaps(IndA_dt, IndB_dt, type="any", nomatch=0L,mult="first")
    
    if (nrow(overlaps)>0){
      first_meeting<-overlaps[overlaps$start==min(overlaps$start),]
      first_meeting<-first_meeting[1,]
      
      date_met<-first_meeting$date_global
      tree_met<-first_meeting$cluster_Tree

    }else{
      date_met<-max(c(min(IndA_dt$date_global),min(IndB_dt$date_global)))
      tree_met<-"None"
    }
    # How many nights were these two tags tracked together?
    total_nights<-min(max(IndB_dt$Night), max(IndB_dt$Night))
    
    nights_obs<-n_nights # choosing how many nights in total to look at (for both bats)
    if (nights_obs<=total_nights){
      nights_min<-"yes"
    }else{
      nights_min<-"no"}
    # I will look at the trees used during the night the bats met and the following 3 nights.
    
    # Identify the shared trees that A has with B from the night they met onward:

    if( tree_type=="un_pred"){ # if the focus is only on new trees that are "unpredictable species" for which information transfer is most likely to be relevant
      OneInd<-OneInd[OneInd$tree_sp %in% unpred_speceis,] # select only unpredictable species
      SecondInd<-SecondInd[SecondInd$tree_sp %in% unpred_speceis,]
      }
    if(nrow(OneInd)==0 | nrow(SecondInd)==0){
      trees_species_A_future<-NA;shared_trees<-NA;prop_shared_A_future<-NA;propA_first_all<-NA;n_shared_trees<-NA;n_shared_trees_all<-NA;n_shared_new_trees<-NA;n_future_trees_A<-NA
      }else{
    # All trees of A from the night they met onward:
    trees_A_future<-unique(OneInd$cluster_Tree[OneInd$date_global>=date_met & OneInd$date_global<= date_met+nights_obs])
    trees_species_A_future<-list(unique(OneInd$tree_sp[OneInd$date_global>=date_met & OneInd$date_global<= date_met+nights_obs]))
    # remove trees of the day they met (not new):
    trees_today_A<-unique(OneInd$cluster_Tree[OneInd$date_global==date_met])
    trees_A_future<-trees_A_future[!trees_A_future %in% trees_today_A]
    n_future_trees_A<-length(trees_A_future)
    
    ######################################################################
    # Now for B - all TREES USED IN THE LAST 3 NIGHTS 
    Past_IndB_dt<- SecondInd[ SecondInd$date_global<=date_met &  SecondInd$date_global>= (date_met-3),]
    trees_B_past<-unique(Past_IndB_dt$cluster_Tree)
    ######################################################################

    shared_trees<-intersect(trees_A_future,trees_B_past)
    # The proportion of NEW trees A used that B visited too: 
    if(n_future_trees_A==0){
      prop_shared_A_future<-0
    }else{
      prop_shared_A_future<-round(length(shared_trees)/n_future_trees_A,digits=2)
    }
    
    
    # Also add - among all trees shared, what is the proportion of tagA arriving to a tree first?
    if(length(shared_trees_all)!=0){
      shared_df<-TwoInds[TwoInds$cluster_Tree %in% shared_trees_all,]
      whos_first_all<-shared_df %>% group_by(cluster_Tree) %>% filter(start==min(start))
      propA_first_all<-round(nrow(whos_first_all[whos_first_all$TAG==IndA,])/nrow(whos_first_all),digits=2)
    }else{
      propA_first_all<-0
    }
    
    # Add relvant identifiers for the table:
    n_shared_trees<-length(shared_trees_all)
    n_shared_new_trees<-length(shared_trees)
      }}
  trees_species_A_future<-ifelse(length(trees_species_A_future)>0,trees_species_A_future,NA)
  AB<-data.frame(IndA,IndB,tree_met,as.Date(date_met),prop_shared_A_future,propA_first_all,n_shared_trees,n_shared_new_trees, n_future_trees_A,nights_min,toString(trees_species_A_future))
  return(AB)
}

##########################################################################################
##########################################################################################

get_psuedo_data<-function(night_files,path,type="obs"){
  
  psuedo_nights_df<-rbindlist(lapply(1:length(night_files), function(f){
    psuedo<-read_csv(paste0(path,night_files[f]))
    psuedo<-psuedo[,-1]
    psuedo<-psuedo[is.na(psuedo$min_nights) | psuedo$min_nights=="yes",]
    psuedo$shared_tree<-ifelse(psuedo$MeetingTree=="None","no","yes")
    name_nights<-gsub("psuedo_following","",night_files[f])
    name_nights<-gsub("Night.csv","",name_nights)
    psuedo$nights_examined<-as.double(name_nights)

    psuedo$period<-NA
    psuedo$pair_ID<-seq(1,nrow(psuedo),1)
    i<-nrow(psuedo)+1
    for (n in 1:nrow(psuedo)){
      row_samp<-psuedo[n,]
      pair_inx1<-which(psuedo$TAGA==row_samp$TAGA & psuedo$TAGB==row_samp$TAGB)
      pair_inx2<-which(psuedo$TAGA== row_samp$TAGB & psuedo$TAGB==row_samp$TAGA)
      if (length(pair_inx1)>0 & length(pair_inx2)>0 & psuedo$pair_ID[n]<nrow(psuedo)+1)
        psuedo$pair_ID[c(pair_inx1,pair_inx2)]<-i
      i<-i+1
    }
    
    
    # max prop used A per pair
    psuedo$pair_ID<-as.character(psuedo$pair_ID)
    
    psuedo_pairs<-psuedo %>% dplyr::group_by(pair_ID,shared_tree,MeetingTree,MeetingDate,n_shared_trees,nights_examined,period) %>% dplyr::summarise(
      "TAGA"=TAGA[prop_A_vis_B==max(prop_A_vis_B)][1],"TAGB"=TAGB[prop_A_vis_B==max(prop_A_vis_B)][1],"prop_visit_any"=max(prop_A_vis_B), "prop_A_first"=prop_A_first[prop_A_vis_B==max(prop_A_vis_B)][1])
    psuedo_pairs$prop_A_second<-ifelse(psuedo_pairs$MeetingTree=="None" |psuedo_pairs$n_shared_trees==0 ,0,1-psuedo_pairs$prop_A_first)
    
    psuedo_pairs$pair_ID<-as.numeric(psuedo_pairs$pair_ID)
    
    psuedo_pairs<-psuedo_pairs[!duplicated(psuedo_pairs$pair_ID),]
    psuedo_pairs$visit_focal<-ifelse(psuedo_pairs$prop_visit_any>0,1,0)
    
    psuedo_pairs$TAGA<-as.character(psuedo_pairs$TAGA)
    psuedo_pairs_ind<-left_join(psuedo_pairs,indTAG1, by=c("TAGA"="TAGA"))
    psuedo_pairs_ind$TAGB<-as.character(psuedo_pairs_ind$TAGB)
    psuedo_pairs_ind<-left_join(psuedo_pairs_ind,indTAG2, by=c("TAGB"="TAGB"))
    
    psuedo_pairs_ind$same_cave<-ifelse(psuedo_pairs_ind$cave_originA==psuedo_pairs_ind$cave_originB,"yes","no")
    return(psuedo_pairs_ind)}))
}
