function[S] = update_settings_post(S)

% Full gait cycle simulations instead of Half gait cycle (default) simulations
S.misc.gaitmotion_type = 'FullGaitCycle';

S.settings.muscle_strength = {...       
	 {'glut_max_r'},0.3,...              	% R_hip_ext   
	 {'glut_max_l'},0.3,...               	% L_hip_ext 
	 {'iliopsoas_r'},0.7,...            	% R_hip_flex    
	 {'iliopsoas_l'},0.7,...             	% L_hip_flex  
	 {'hamstrings_r' 'bifemsh_r'},0.3,...  	% R_knee_flex %% to edit
	 {'hamstrings_l' 'bifemsh_l'},0.3,...  	% L_knee_flex %% to edit
	 {'rect_fem_r' 'vasti_r'},0.5,...      	% R_knee_ext  %% to edit
	 {'rect_fem_l' 'vasti_l'},0.7,...      	% L_knee_ext  %% to edit
	 {'gastroc_r' 'soleus_r'},0.3,...     	% R_ankle_pf  
	 {'gastroc_l' 'soleus_l'},0.5,...     	% L_ankle_pf
	 {'tib_ant_r'},0.3,...               	% R_ankle_df  
	 {'tib_ant_l'},0.3};                 	% L_ankle_df 

S.subject.scale_MT_params = {{'hamstrings_r'},'lMo',0.88,... 	% pROM_Poplbi_R %% to edit 
								{'hamstrings_l'},'lMo',0.91,... % pROM_Poplbi_L %% to edit 
								{'iliopsoas_r'},'lMo',1,...  	% explained in step 4
								{'iliopsoas_l'},'lMo',0.74,... 	% explained in step 4  (%% to edit)
								{'gastroc_r'},'lMo',1,...		% pROM_Ankledf0_R
								{'gastroc_l'},'lMo',1,...		% pROM_Ankledf0_L
								{'soleus_r'},'lMo',1,... 		% pROM_Ankledf90_R
								{'soleus_l'},'lMo',1};			% pROM_Ankledf90_L


S.subject.set_limit_torque_coefficients_selected_dofs =...
		{{'lumbar_extension'},[-0.7644,11.2154,1.2788,-7.2704], [-0.3716,0.1068],...
        {'hip_flexion_r','hip_flexion_l'},[-2.44,5.05,1.51,-21.88],[-0.6981,1.81],...
        {'knee_angle_r','knee_angle_l'},[-6.09,33.94,11.03,-11.33],[-2.4,0],... %% to edit
        {'ankle_angle_r','ankle_angle_l'},[-2.03,38.11,0.18,-12.12],[-0.4363,0.6109]};

end