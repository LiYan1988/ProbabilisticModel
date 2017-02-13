function exp = prob8_7(k, h, i)
% expectation of the number of segments that have k hops in a h-hop path
% with i+1 segments, i.e., i regenerators
exp = (i+1)*prob8_6(k, h, i);