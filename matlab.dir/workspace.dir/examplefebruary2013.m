function [] = examplefebruary2013()
warning off
set_path_had
ds = csvread('/datas/xlan/hours/akamai/datasets/02082012_02112012.dir/csvfiles/psql_output_0802_1102_without_loss_cache.csv',1,0);
time_distance_rtt = ds(:,[1,2,4]);
[X,Y,Zlin,Zcub,Zv4,Znr,Zlinflatten,Zcubflatten,Zv4flatten,Znrflatten] = extrapolate(time_distance_rtt,size(ds,1)*3,{'begining24','distance','rtt_tcp_hs'});
csvwrite('/datas/xlan/hours/akamai/datasets/02082012_02112012.dir/csvfiles/X.csv',X);
csvwrite('/datas/xlan/hours/akamai/datasets/02082012_02112012.dir/csvfiles/Y.csv',Y);
csvwrite('/datas/xlan/hours/akamai/datasets/02082012_02112012.dir/csvfiles/Zlin.csv',Zlin);
csvwrite('/datas/xlan/hours/akamai/datasets/02082012_02112012.dir/csvfiles/Zcub.csv',Zcub);
csvwrite('/datas/xlan/hours/akamai/datasets/02082012_02112012.dir/csvfiles/Zv4.csv',Zv4);
csvwrite('/datas/xlan/hours/akamai/datasets/02082012_02112012.dir/csvfiles/Znr.csv',Znr);
csvwrite('/datas/xlan/hours/akamai/datasets/02082012_02112012.dir/csvfiles/Zlinflatten.csv',Zlinflatten);
csvwrite('/datas/xlan/hours/akamai/datasets/02082012_02112012.dir/csvfiles/Zcubflatten.csv',Zcubflatten);
csvwrite('/datas/xlan/hours/akamai/datasets/02082012_02112012.dir/csvfiles/Zv4flatten.csv',Zv4flatten);
csvwrite('/datas/xlan/hours/akamai/datasets/02082012_02112012.dir/csvfiles/Znrflatten.csv',Znrflatten);
