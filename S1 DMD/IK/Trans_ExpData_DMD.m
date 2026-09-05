load('ExpData_Case_DMD.mat')

%swap
idx_ref = strcmp(ExpData_Case_DMD.kinematics.colheaders,'pelvis_tilt');
ExpData_Case_DMD.kinematics.mean(:,idx_ref) = -ExpData_Case_DMD.kinematics.mean(:,idx_ref);

idx_ref = strcmp(ExpData_Case_DMD.kinematics.colheaders,'knee_angle');
ExpData_Case_DMD.kinematics.mean(:,idx_ref) = -ExpData_Case_DMD.kinematics.mean(:,idx_ref);

idx_ref = strcmp(ExpData_Case_DMD.kinematics.colheaders,'lumbar_extension');
ExpData_Case_DMD.kinematics.mean(:,idx_ref) = -ExpData_Case_DMD.kinematics.mean(:,idx_ref);

idx_ref = strcmp(ExpData_Case_DMD.kinematics.colheaders,'pelvis_list');
ExpData_Case_DMD.kinematics.mean(:,idx_ref) = -ExpData_Case_DMD.kinematics.mean(:,idx_ref);

idx_ref = strcmp(ExpData_Case_DMD.kinematics.colheaders,'lumbar_bending');
ExpData_Case_DMD.kinematics.mean(:,idx_ref) = -ExpData_Case_DMD.kinematics.mean(:,idx_ref);

idx_ref = strcmp(ExpData_Case_DMD.torques.colheaders,'hip_flexion');
ExpData_Case_DMD.torques.mean(:,idx_ref) = -ExpData_Case_DMD.torques.mean(:,idx_ref);

idx_ref = strcmp(ExpData_Case_DMD.torques.colheaders,'hip_adduction');
ExpData_Case_DMD.torques.mean(:,idx_ref) = -ExpData_Case_DMD.torques.mean(:,idx_ref);

idx_ref = strcmp(ExpData_Case_DMD.torques.colheaders,'ankle_angle');
ExpData_Case_DMD.torques.mean(:,idx_ref) = -ExpData_Case_DMD.torques.mean(:,idx_ref);

% offset 
idx_ref = strcmp(ExpData_Case_DMD.kinematics.colheaders,'pelvis_tilt');
ExpData_Case_DMD.kinematics.mean(:,idx_ref) = ExpData_Case_DMD.kinematics.mean(:,idx_ref) + 13;

idx_ref = strcmp(ExpData_Case_DMD.kinematics.colheaders,'hip_flexion');
ExpData_Case_DMD.kinematics.mean(:,idx_ref) = ExpData_Case_DMD.kinematics.mean(:,idx_ref) + 13;


idx_ref = strcmp(ExpData_Case_DMD.kinematics.mean,'lumbar_extension');
ExpData_Case_DMD.kinematics.mean(:,idx_ref) = ExpData_Case_DMD.kinematics.mean(:,idx_ref) - 13;


    
% rename
idx_ref = strcmp(ExpData_Case_DMD.kinematics.colheaders,'pelvis_tilt');
ExpData_Case_DMD.kinematics.colheaders{idx_ref} = 'pelvis_ant_tilt';

idx_ref = strcmp(ExpData_Case_DMD.kinematics.colheaders,'knee_angle');
ExpData_Case_DMD.kinematics.colheaders{idx_ref} = 'knee_flexion';

idx_ref = strcmp(ExpData_Case_DMD.kinematics.colheaders,'lumbar_extension');
ExpData_Case_DMD.kinematics.colheaders{idx_ref} = 'lumbar_flexion';

idx_ref = strcmp(ExpData_Case_DMD.kinematics.colheaders,'pelvis_rotation');
ExpData_Case_DMD.kinematics.colheaders{idx_ref} = 'pelvis_int_rotation';

idx_ref = strcmp(ExpData_Case_DMD.kinematics.colheaders,'lumbar_rotation');
ExpData_Case_DMD.kinematics.colheaders{idx_ref} = 'lumbar_int_rotation';

idx_ref = strcmp(ExpData_Case_DMD.kinematics.colheaders,'pelvis_list');
ExpData_Case_DMD.kinematics.colheaders{idx_ref} = 'pelvis_up';

idx_ref = strcmp(ExpData_Case_DMD.kinematics.colheaders,'lumbar_bending');
ExpData_Case_DMD.kinematics.colheaders{idx_ref} = 'lumbar_up';

idx_ref = strcmp(ExpData_Case_DMD.torques.colheaders,'hip_flexion');
ExpData_Case_DMD.torques.colheaders{idx_ref} = 'hip_extension';

idx_ref = strcmp(ExpData_Case_DMD.torques.colheaders,'hip_adduction');
ExpData_Case_DMD.torques.colheaders{idx_ref} = 'hip_abduction';

idx_ref = strcmp(ExpData_Case_DMD.torques.colheaders,'ankle_angle');
ExpData_Case_DMD.torques.colheaders{idx_ref} = 'ankle_plantar_flexion';



ExpData_Case_DMD_transf = ExpData_Case_DMD;

save('ExpData_Case_DMD_transf.mat', 'ExpData_Case_DMD_transf');