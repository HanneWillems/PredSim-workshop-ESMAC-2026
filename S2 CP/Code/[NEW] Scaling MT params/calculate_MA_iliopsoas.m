function [MA] = calculate_MA_iliopsoas(side,model_info,sf_lMo_prev,coordinates,f_lMT_vMT_dM,CE_angle)
% calculate_MA_iliopsoas
%   Computes muscle–tendon moment arms (MA) for a hamstrings-based clinical
%   exam posture, to be used in the calibration of iliopsoas parameters.
%   The function:
%   (1) builds a quasi-static clinical exam configuration using
%       get_CE_position with muscle_toScale = 'hamstrings',
%   (2) applies previously chosen lMo scaling factors for soleus,
%       gastrocnemii and hamstrings on the selected side,
%   (3) updates muscle–tendon parameters via scale_MTparameters, and
%   (4) evaluates the CasADi function f_lMT_vMT_dM to obtain muscle–tendon
%       lengths, velocities and moment arms over the defined range of
%       joint angles.
%   The computed moment arms are returned for further use (e.g. in
%   passive torque calculations or iliopsoas calibration routines).
%
% INPUT:
%   - side -
%   * string/char indicating the side of interest:
%       > 'l' : left
%       > 'r' : right
%
%   - model_info -
%   * struct containing model and muscle information, including
%     model_info.muscle_info.parameters with fields such as FMo, lMo,
%     lTs, alphao, vMmax, specific_tension, tendon_stiff, etc.
%
%   - sf_lMo_prev -
%   * struct with previously defined lMo scaling factors for distal and
%     hamstring muscles on the selected side, organised as:
%       sf_lMo_prev.(side).soleus
%       sf_lMo_prev.(side).gastrocnemii
%       sf_lMo_prev.(side).hamstrings
%     These are applied before computing moment arms.
%
%   - coordinates -
%   * cell array of coordinate names from the model; passed to
%     get_CE_position and used by f_lMT_vMT_dM
%
%   - f_lMT_vMT_dM -
%   * CasADi function handle returning muscle–tendon lengths, velocities
%     and moment arms:
%       [lMT, vMT, MA] = f_lMT_vMT_dM(Qs(i,:), Qdots(i,:))
%
%   - CE_angle -
%   * clinical exam knee angle (in degrees) around which a ±20° range of
%     motion is constructed by get_CE_position for the hamstrings posture
%
% OUTPUT:
%   - MA -
%   * matrix of muscle–tendon moment arms (size: NMuscle × NCoordinates)
%     evaluated over the clinical exam range of motion; as returned by
%     f_lMT_vMT_dM (last evaluated step)
% Original authors: Bram Van Den Bosch, Ellis Van Can
% Original date: September 13, 2024

% Last edit by: Ellis Van Can
% Last edit date: November 19, 2025
% --------------------------------------------------------------------------
close all % close previous figs
sf_lMo = 1;

S.subject.St = 1;
muscle_toScale = 'hamstrings';
[Qs,Qdots,idx_joint,coord_name] = get_CE_position(CE_angle,muscle_toScale,side,coordinates);
n = length(Qs);
coord_name_side = [coord_name,'_',side];

for j = 1:length(sf_lMo)
    if strcmp(muscle_toScale,'soleus')
        scale.subject.scale_MT_params = {{['soleus_',side]},'lMo',sf_lMo_prev(j)};
    elseif strcmp(muscle_toScale,'gastrocnemii')
        scale.subject.scale_MT_params = {{['soleus_',side]},'lMo',sf_lMo_prev.(side).soleus,...
            {['gastroc_',side]},'lMo',sf_lMo_prev(j)};
    elseif strcmp(muscle_toScale,'hamstrings')
        scale.subject.scale_MT_params = {{['soleus_',side]},'lMo',sf_lMo_prev.(side).soleus,...
            {['gastroc_',side]},'lMo',sf_lMo_prev.(side).gastrocnemii,...
            {['hamstrings_',side]},'lMo',sf_lMo(j)};

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
    % 
    % f1 = gcf;
    % 
    % figure(f1)
    % plot(Qs(:,idx_joint)*180/pi,M_tot,'DisplayName',['sf lMo at ' num2str(sf_lMo(j)*100) '%']); 
    % hold on;

end

% title(['passive torque-angle relationship ',strrep(muscle_toScale, '_', ' '),' ', side]);
% xline(CE_angle, 'HandleVisibility','off');
% yline(-15, 'HandleVisibility','off');
% ylabel('Torque (Nm)')
% xlabel([strrep(coord_name_side, '_', ' '),' (°)'])
% ylim([-20 0])
% 
% legend