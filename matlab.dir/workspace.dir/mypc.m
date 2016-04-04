function [G] = mypc(testindependence,N,varargin)
%This function implements the pc algorithm and use bnt implementation of
%Pearl improvements of Meek rules for orientation
%Use
%       Graph = mypc(testindependence,N,vargin)

[skel,sepset] = skeleton(N,testindependence,varargin{:});
G = orientEdges(skel,sepset);