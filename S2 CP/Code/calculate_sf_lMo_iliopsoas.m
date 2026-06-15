function calculate_sf_lMo_iliopsoas(sf_lMo,muscle_toScale,side,model_info,sf_lMo_prev,Qs,Qdots,coordinates,f_lMT_vMT_dM,idx_joint,coord_name,CE_angle)
% calculate_sf_lMo_iliopsoas
%   Evaluates the effect of different optimal fibre length scaling factors
%   (lMo) for iliopsoas (and associated muscles) on the passive
%   torque–angle relationship around a selected joint during a clinical
%   exam–like posture. For each scaling factor in sf_lMo, the function:
%   (1) updates muscle–tendon parameters via scale_MTparameters,
%   (2) solves Hill-type muscle–tendon force equilibrium over a range of
%   joint angles using fsolve and getHilldiffFun_usingCasadiFunction,
%   (3) computes the resulting muscle moments and passive joint torque,
%   and (4) plots the total passive torque versus joint angle. The figure
%   can be used to visually select a scaling factor that best matches the
%   clinically observed passive torque at the clinical exam angle.
%
% INPUT:
%   - sf_lMo -
%   * vector with candidate scaling factors for the iliopsoas optimal
%     fibre length (expressed as multiplicative factors, e.g. 0.9–1.1)
%
%   - muscle_toScale -
%   * string/char specifying which muscle group is being scaled; expected
%     to include 'iliopsoas' (other options are handled for completeness):
%       > 'soleus'
%       > 'gastrocnemii'
%       > 'hamstrings'
%       > 'iliopsoas'
%
%   - side -
%   * string/char indicating the side of the muscle to scale:
%       > 'l' : left
%       > 'r' : right
%
%   - model_info -
%   * struct containing model and muscle information, including
%     model_info.muscle_info.parameters with fields such as FMo, lMo,
%     lTs, alphao, vMmax, specific_tension, tendon_stiff, etc.
%
%   - sf_lMo_prev -
%   * struct with previously defined lMo scaling factors for other
%     muscles and/or sides, organised as:
%       sf_lMo_prev.(side).soleus
%       sf_lMo_prev.(side).gastrocnemii
%       sf_lMo_prev.(side).hamstrings
%       sf_lMo_prev.(other_side).hamstrings
%     These are used to keep distal and contralateral muscles at their
%     already-chosen scaling while varying iliopsoas.
%
%   - Qs -
%   * matrix (n × nCoordinates) of joint angles (in radians) over the
%     range of motion used to evaluate passive torque; typically generated
%     by a get_CE_position* function
%
%   - Qdots -
%   * matrix (n × nCoordinates) of joint angular velocities; usually zero
%     for quasi-static passive analyses
%
%   - coordinates -
%   * cell array of coordinate names from the model, consistent with the
%     columns expected by f_lMT_vMT_dM
%
%   - f_lMT_vMT_dM -
%   * CasADi function handle that returns muscle–tendon lengths,
%     velocities and moment arms:
%       [lMT, vMT, MA] = f_lMT_vMT_dM(Qs(i,:), Qdots(i,:))
%
%   - idx_joint -
%   * index of the joint coordinate in 'coordinates' about which the
%     passive torque–angle relationship is evaluated
%
%   - coord_name -
%   * base name of the joint coordinate (e.g. 'hip_flexion'); used for
%     passing to getLimitTorque and for labeling the plot
%
%   - CE_angle -
%   * clinical exam angle (in degrees) at which the passive torque is
%     typically compared; used only for plotting a vertical reference line
%
% OUTPUT:
%   - (none)
%   * The function produces a figure with curves of total passive joint
%     torque versus joint angle for each scaling factor in sf_lMo, and
%     adds a legend indicating the percentage lMo scaling.

% Original authors: Bram Van Den Bosch, Ellis Van Can
% Original date: September 13, 2024

% Last edit by: Ellis Van Can
% Last edit date: November 19, 2025
% --------------------------------------------------------------------------


% Loop that evaluates the scaling factors
close all % close previous figs

n = length(Qs);
S.subject.St = 1;


if strcmp(side,'r')
    other_side = 'l';
elseif strcmp(side,'l')
    other_side = 'r';
end
coord_name_side = [coord_name,'_',other_side];

for j = 1:length(sf_lMo)
    if strcmp(muscle_toScale,'soleus')
        scale.subject.scale_MT_params = {{['soleus_',side]},'lMo',sf_lMo_prev(j)};
    elseif strcmp(muscle_toScale,'gastrocnemii')
        scale.subject.scale_MT_params = {{['soleus_',side]},'lMo',sf_lMo_prev.(side).soleus,...
            {['gastroc_',side]},'lMo',sf_lMo_prev(j)};
    elseif strcmp(muscle_toScale,'hamstrings')
        scale.subject.scale_MT_params = {{['gastroc_',side]},'lMo',sf_lMo_prev.(side).gastrocnemii,...
            {['hamstrings_',side]},'lMo',sf_lMo(j)};
    elseif strcmp(muscle_toScale,'iliopsoas')
        scale.subject.scale_MT_params = {{['soleus_',side]},'lMo',sf_lMo_prev.(side).soleus,...
            {['gastroc_',side]},'lMo',sf_lMo_prev.(side).gastrocnemii,...
            {['hamstrings_',side]},'lMo',sf_lMo_prev.(side).hamstrings,...
            {['hamstrings_',other_side]},'lMo',sf_lMo_prev.(other_side).hamstrings,...
            {['iliopsoas_',other_side]},'lMo',sf_lMo(j)};
    end


    % muscle strength
    if ~isfield(scale.subject,'muscle_strength')
        scale.subject.muscle_strength = [];
    end
    
    % muscle stiffness
    if ~isfield(scale.subject,'muscle_pass_stiff_shift')
        scale.subject.muscle_pass_stiff_shift = [];
    end
    if ~isfield(scale.subject,'muscle_pass_stiff_scale')
        scale.subject.muscle_pass_stiff_scale = [];
    end
    
    % tendon stiffness
    if ~isfield(scale.subject,'tendon_stiff_scale')
        scale.subject.tendon_stiff_scale = [];
    end
   
    % % get strength scaling factors
    if ~isempty(scale)
        try
            % scale
            [sf_model_info.muscle_info] = scale_MTparameters(scale,model_info.muscle_info);
        catch errmsg
            error(['Unable to extract strength scale factor because: ', errmsg.message]);
        end
    end
    
    
    % Solve the muscle-tendon force equilibrium for the given length and
    % activation to find the total force along the tendon.
    
    % n = 1; % number of timepoints
    options = optimset('Display','off');
    
    load Fvparam
    load Fpparam
    load Faparam
    
    FMo_in = struct_array_to_double_array(sf_model_info.muscle_info.parameters,'FMo');
    lMo_in = struct_array_to_double_array(sf_model_info.muscle_info.parameters,'lMo');
    lTs_in = struct_array_to_double_array(sf_model_info.muscle_info.parameters,'lTs');
    alphao_in = struct_array_to_double_array(sf_model_info.muscle_info.parameters,'alphao');
    vMmax_in = struct_array_to_double_array(sf_model_info.muscle_info.parameters,'vMmax');
    tension = struct_array_to_double_array(sf_model_info.muscle_info.parameters,'specific_tension');
    aTendon = struct_array_to_double_array(sf_model_info.muscle_info.parameters,'tendon_stiff');
    shift = struct_array_to_double_array(sf_model_info.muscle_info.parameters,'tendon_stiff_shift');
    stiffness_shift = struct_array_to_double_array(sf_model_info.muscle_info.parameters,'muscle_pass_stiff_shift');
    stiffness_scale = struct_array_to_double_array(sf_model_info.muscle_info.parameters,'muscle_pass_stiff_scale');
    strength = struct_array_to_double_array(sf_model_info.muscle_info.parameters,'muscle_strength');
    
    a = ones(sf_model_info.muscle_info.NMuscle,1)*0.01; % activation
    fse  = zeros(sf_model_info.muscle_info.NMuscle,1); % tendon force-length characteristic 
    dfse = 0;
    
    vMT  = 0; % MT velocity
    
    MuscMoAsmp = 0; % constant pennation angle
    d = 0.01; % muscle damping
    
    lMT = zeros(sf_model_info.muscle_info.NMuscle,n);
    FT = zeros(n,sf_model_info.muscle_info.NMuscle); 
    M_muscle = zeros(sf_model_info.muscle_info.NMuscle,n);
    Tau_pass = zeros(1,n);
    
    for i=1:n
        % evaluate casadi function to get MT lengths and moment arms
        [lMTj,vMTj,MAj] =  f_lMT_vMT_dM(Qs(i,:),Qdots(i,:));
        
        lMT(:,i) = full(lMTj);
        vMTj = full(vMTj);
        MA = full(MAj);
    
        l_MT = lMT(:,i);
        FT_tmp = fsolve('getHilldiffFun_usingCasadiFunction',fse,options,a,dfse,l_MT,vMT,FMo_in,lMo_in,...
                    lTs_in,alphao_in,vMmax_in,Fvparam,Fpparam,Faparam,tension,aTendon,shift,...
                    MuscMoAsmp,d,stiffness_shift,stiffness_scale,strength);
    
        FT(i,:) = FT_tmp.*FMo_in;
        M_muscle(:,i) = FT(i,:)'.*MA(:,idx_joint); % muscle moments
        [Tau_pass(:,i)] = getLimitTorque(coord_name, Qs(i,idx_joint)*180/pi, S.subject.St); % calculate limit torques
    end
    
    
    % calculate moments
   
    M_tot = sum(M_muscle)+Tau_pass;
    
    % plot
    
    f1 = gcf;
    figure(f1)
    plot(Qs(:,idx_joint)*180/pi,M_tot,'DisplayName',['sf lMo at ' num2str(sf_lMo(j)*100) '%']); 
    hold on;
end

title(['passive torque-angle relationship ',strrep(muscle_toScale, '_', ' '),' ', other_side]);
xline(CE_angle, 'HandleVisibility','off');
yline(0, 'HandleVisibility','off');
ylabel('Torque (Nm)')
xlabel([strrep(coord_name_side, '_', ' '),' (°)'])
ylim([-10 10])

legend