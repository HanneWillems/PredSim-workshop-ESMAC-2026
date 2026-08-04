function Hilldiff_fun = getHilldiffFun_usingCasadiFunction(fse,a,dfse,lMT,vMT,FMo_in,lMo_in,...
    lTs_in,alphao_in,vMmax_in,Fvparam,Fpparam,Faparam,tension,aTendon,shift,...
    MuscMoAsmp,d,stiffness_shift,stiffness_scale,strength)
% getHilldiffFun
%   Computes the Hill-type muscle force equilibrium residual for multiple
%   muscles by evaluating the difference between muscle-tendon force and
%   tendon force for each muscle element. This function acts as a wrapper
%   around ForceEquilibrium_FtildeState_all_tendon and returns the
%   force equilibrium error (Hill difference) for use in implicit muscle
%   dynamics or optimisation routines.
%
% INPUT:
%   - fse -
%   * vector of normalised tendon forces for each muscle
%
%   - a -
%   * vector of muscle activations
%
%   - dfse -
%   * time derivative of normalised tendon force
%
%   - lMT -
%   * vector of muscle-tendon lengths
%
%   - vMT -
%   * vector of muscle-tendon velocities
%
%   - FMo_in -
%   * vector of maximum isometric muscle forces
%
%   - lMo_in -
%   * vector of optimal muscle fibre lengths
%
%   - lTs_in -
%   * vector of tendon slack lengths
%
%   - alphao_in -
%   * vector of pennation angles at optimal fibre length
%
%   - vMmax_in -
%   * vector of maximum muscle fibre contraction velocities
%
%   - Fvparam, Fpparam, Faparam -
%   * parameter sets for force-velocity, passive force-length and active
%     force-length muscle curves
%
%   - tension -
%   * vector indicating tendon tension state
%
%   - aTendon -
%   * vector of tendon activation factors
%
%   - shift -
%   * vector of shifts applied to the force-length curves
%
%   - MuscMoAsmp -
%   * assumption or mode for muscle model formulation
%
%   - d -
%   * damping coefficient used in the muscle model
%
%   - stiffness_shift -
%   * vector shifting tendon stiffness characteristics
%
%   - stiffness_scale -
%   * vector scaling tendon stiffness characteristics
%
%   - strength -
%   * vector scaling muscle strength
%
% OUTPUT:
%   - Hilldiff_fun -
%   * vector containing the force equilibrium residual for each muscle,
%     where zero indicates perfect force equilibrium
% Original author: Bram Van Den Bosch
% Original date: xx/xx/xxxx

% Last edit by: 
% Last edit date: 
% --------------------------------------------------------------------------
N_fun = length(lMT);
Hilldiff_fun = zeros(size(fse));

for m = 1:N_fun
    [Hilldiff_tmp,~,~,~,~,~,~] = ...
        ForceEquilibrium_FtildeState_all_tendon(a(m),fse(m),dfse,lMT(m),vMT,...
        FMo_in(m),lMo_in(m),lTs_in(m),alphao_in(m),vMmax_in(m),...
        Fvparam,Fpparam,Faparam,...
        tension(m),aTendon(m),shift(m),MuscMoAsmp,d,stiffness_shift(m),stiffness_scale(m),strength(m));

    Hilldiff_fun(m) = Hilldiff_tmp;
end

end