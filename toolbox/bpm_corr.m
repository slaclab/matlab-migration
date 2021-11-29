function [orx_c, ory_c]= bpm_corr(orbitx,sigmax,orbity,sigmay,kicks,bpmList)

bpm_corr_vals=[0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
];
[orbitxc,orbityc] = rot_scale(orbitx,orbity,bpm_corr_vals);
[orx_c,sigma_orx,rsq_orx,ory_c,sigma_ory,rsq_ory]=get_orm(orbitxc,sigmax,orbityc,sigmay,kicks,bpmList);