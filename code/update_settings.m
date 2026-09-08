function[S] = update_settings(S)

% Default settings
% Full gait cycle simulations instead of Half gait cycle (default) simulations
S.misc.gaitmotion_type = 'FullGaitCycle';

% Default settings of gait1018_esmac
% Achilles tendon stiffness
S.subject.tendon_stiff_scale = {{'gastroc'},0.5,{'soleus'},0.5};

% Adjust TA length and optimal force
S.subject.scale_MT_params = {{'tib_ant_l','tib_ant_r'},'lMo',0.85,{'tib_ant_l','tib_ant_r'},'FMo',0.5};

% Lower bound on activations
S.bounds.activation_all_muscles.lower = 0.01;

S.subject.muscle_pass_stiff_shift = {{'iliopsoas_l', 'iliopsoas_r'}, 0.9};

S.subject.muscle_pass_stiff_scale = {{'iliopsoas_l', 'iliopsoas_r'}, 2.5, {'gastroc_l','gastroc_r'}, 3};

end