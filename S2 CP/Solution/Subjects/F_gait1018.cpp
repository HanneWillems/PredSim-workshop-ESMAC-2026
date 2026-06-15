#include <OpenSim/Simulation/Model/Model.h>
#include <OpenSim/Simulation/SimbodyEngine/PinJoint.h>
#include <OpenSim/Simulation/SimbodyEngine/WeldJoint.h>
#include <OpenSim/Simulation/SimbodyEngine/PlanarJoint.h>
#include <OpenSim/Simulation/SimbodyEngine/Joint.h>
#include <OpenSim/Simulation/SimbodyEngine/SpatialTransform.h>
#include <OpenSim/Simulation/SimbodyEngine/CustomJoint.h>
#include <OpenSim/Common/LinearFunction.h>
#include <OpenSim/Common/PolynomialFunction.h>
#include <OpenSim/Common/MultiplierFunction.h>
#include <OpenSim/Common/Constant.h>
#include <OpenSim/Simulation/Model/SmoothSphereHalfSpaceForce.h>
#include "SimTKcommon/internal/recorder.h"

#include <iostream>
#include <iterator>
#include <random>
#include <cassert>
#include <algorithm>
#include <vector>
#include <fstream>

using namespace SimTK;
using namespace OpenSim;

constexpr int n_in = 2; 
constexpr int n_out = 1; 
constexpr int nCoordinates = 10; 
constexpr int NX = nCoordinates*2; 
constexpr int NU = 10; 
constexpr int NR = 38; 

template<typename T> 
T value(const Recorder& e) { return e; }; 
template<> 
double value(const Recorder& e) { return e.getValue(); }; 

SimTK::Array_<int> getIndicesOSInSimbody(const Model& model) { 
	auto s = model.getWorkingState(); 
	const auto svNames = model.getStateVariableNames(); 
	SimTK::Array_<int> idxOSInSimbody(s.getNQ()); 
	s.updQ() = 0; 
	for (int iy = 0; iy < s.getNQ(); ++iy) { 
		s.updQ()[iy] = SimTK::NaN; 
		const auto svValues = model.getStateVariableValues(s); 
		for (int isv = 0; isv < svNames.size(); ++isv) { 
			if (SimTK::isNaN(svValues[isv])) { 
				s.updQ()[iy] = 0; 
				idxOSInSimbody[iy] = isv/2; 
				break; 
			} 
		} 
	} 
	return idxOSInSimbody; 
} 

SimTK::Array_<int> getIndicesSimbodyInOS(const Model& model) { 
	auto idxOSInSimbody = getIndicesOSInSimbody(model); 
	auto s = model.getWorkingState(); 
	SimTK::Array_<int> idxSimbodyInOS(s.getNQ()); 
	for (int iy = 0; iy < s.getNQ(); ++iy) { 
		for (int iyy = 0; iyy < s.getNQ(); ++iyy) { 
			if (idxOSInSimbody[iyy] == iy) { 
				idxSimbodyInOS[iy] = iyy; 
				break; 
			} 
		} 
	} 
	return idxSimbodyInOS; 
} 

template<typename T>
int F_generic(const T** arg, T** res) {

	// Definition of model.
	OpenSim::Model* model;
	model = new OpenSim::Model();

	// Definition of bodies.
	OpenSim::Body* pelvis;
	pelvis = new OpenSim::Body("pelvis", 9.71433360917239951959, Vec3(-0.06827779999999999960, 0.00000000000000000000, 0.00000000000000000000), Inertia(0.08149288460503059661, 0.08149288460503059661, 0.04454275915306669942, 0., 0., 0.));
	model->addBody(pelvis);

	OpenSim::Body* femur_l;
	femur_l = new OpenSim::Body("femur_l", 7.67231915023828037192, Vec3(0.00000000000000000000, -0.17046700000000000741, 0.00000000000000000000), Inertia(0.11105547289013900647, 0.02911162881586160101, 0.11711002817093099648, 0., 0., 0.));
	model->addBody(femur_l);

	OpenSim::Body* femur_r;
	femur_r = new OpenSim::Body("femur_r", 7.67231915023828037192, Vec3(0.00000000000000000000, -0.17046700000000000741, 0.00000000000000000000), Inertia(0.11105547289013900647, 0.02911162881586160101, 0.11711002817093099648, 0., 0., 0.));
	model->addBody(femur_r);

	OpenSim::Body* tibia_l;
	tibia_l = new OpenSim::Body("tibia_l", 3.05815503574820990451, Vec3(0.00000000000000000000, -0.18048900000000001054, 0.00000000000000000000), Inertia(0.03885269965973540268, 0.00393152317985418030, 0.03939232048834290234, 0., 0., 0.));
	model->addBody(tibia_l);

	OpenSim::Body* tibia_r;
	tibia_r = new OpenSim::Body("tibia_r", 3.05815503574820990451, Vec3(0.00000000000000000000, -0.18048900000000001054, 0.00000000000000000000), Inertia(0.03885269965973540268, 0.00393152317985418030, 0.03939232048834290234, 0., 0., 0.));
	model->addBody(tibia_r);

	OpenSim::Body* talus_l;
	talus_l = new OpenSim::Body("talus_l", 0.08248563818606099995, Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), Inertia(0.00068896770091018196, 0.00068896770091018196, 0.00068896770091018196, 0., 0., 0.));
	model->addBody(talus_l);

	OpenSim::Body* talus_r;
	talus_r = new OpenSim::Body("talus_r", 0.08248563818606099995, Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), Inertia(0.00068896770091018196, 0.00068896770091018196, 0.00068896770091018196, 0., 0., 0.));
	model->addBody(talus_r);

	OpenSim::Body* calcn_l;
	calcn_l = new OpenSim::Body("calcn_l", 1.03107047732575995980, Vec3(0.09139239999999999864, 0.02741769999999999971, 0.00000000000000000000), Inertia(0.00096455478127425401, 0.00268697403354970984, 0.00282476757373175021, 0., 0., 0.));
	model->addBody(calcn_l);

	OpenSim::Body* calcn_r;
	calcn_r = new OpenSim::Body("calcn_r", 1.03107047732575995980, Vec3(0.09139239999999999864, 0.02741769999999999971, 0.00000000000000000000), Inertia(0.00096455478127425401, 0.00268697403354970984, 0.00282476757373175021, 0., 0., 0.));
	model->addBody(calcn_r);

	OpenSim::Body* toes_l;
	toes_l = new OpenSim::Body("toes_l", 0.17866389231100798796, Vec3(0.03162179999999999852, 0.00548355000000000023, 0.01599369999999999958), Inertia(0.00006889677009101820, 0.00013779354018203600, 0.00006889677009101820, 0., 0., 0.));
	model->addBody(toes_l);

	OpenSim::Body* toes_r;
	toes_r = new OpenSim::Body("toes_r", 0.17866389231100798796, Vec3(0.03162179999999999852, 0.00548355000000000023, -0.01599369999999999958), Inertia(0.00006889677009101820, 0.00013779354018203600, 0.00006889677009101820, 0., 0., 0.));
	model->addBody(toes_r);

	OpenSim::Body* torso;
	torso = new OpenSim::Body("torso", 28.24027800320899928010, Vec3(-0.02897220000000000004, 0.30903700000000000614, 0.00000000000000000000), Inertia(1.14043571182128999908, 0.59340091928589699943, 1.14043571182128999908, 0., 0., 0.));
	model->addBody(torso);

	// Definition of joints.
	OpenSim::PlanarJoint* groundPelvis;
	groundPelvis = new OpenSim::PlanarJoint("groundPelvis", model->getGround(), Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), *pelvis, Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000));

	OpenSim::PinJoint* hip_l;
	hip_l = new OpenSim::PinJoint("hip_l", *pelvis, Vec3(-0.06827780017111789723, -0.06383539733113009762, -0.08233069400586880138), Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), *femur_l, Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000));

	OpenSim::PinJoint* hip_r;
	hip_r = new OpenSim::PinJoint("hip_r", *pelvis, Vec3(-0.06827780017111789723, -0.06383539733113009762, 0.08233069400586880138), Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), *femur_r, Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000));

	OpenSim::PinJoint* knee_l;
	knee_l = new OpenSim::PinJoint("knee_l", *femur_l, Vec3(-0.00451221232146797966, -0.39690724592144699390, 0.00000000000000000000), Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), *tibia_l, Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000));

	OpenSim::PinJoint* knee_r;
	knee_r = new OpenSim::PinJoint("knee_r", *femur_r, Vec3(-0.00451221232146797966, -0.39690724592144699390, 0.00000000000000000000), Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), *tibia_r, Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000));

	OpenSim::PinJoint* ankle_l;
	ankle_l = new OpenSim::PinJoint("ankle_l", *tibia_l, Vec3(0.00000000000000000000, -0.41569482537490498597, 0.00000000000000000000), Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), *talus_l, Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000));

	OpenSim::PinJoint* ankle_r;
	ankle_r = new OpenSim::PinJoint("ankle_r", *tibia_r, Vec3(0.00000000000000000000, -0.41569482537490498597, 0.00000000000000000000), Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), *talus_r, Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000));

	OpenSim::WeldJoint* subtalar_l;
	subtalar_l = new OpenSim::WeldJoint("subtalar_l", *talus_l, Vec3(-0.04457209191173210072, -0.03833912765423740099, -0.00723828107321955981), Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), *calcn_l, Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000));

	OpenSim::WeldJoint* subtalar_r;
	subtalar_r = new OpenSim::WeldJoint("subtalar_r", *talus_r, Vec3(-0.04457209191173210072, -0.03833912765423740099, 0.00723828107321955981), Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), *calcn_r, Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000));

	OpenSim::WeldJoint* mtp_l;
	mtp_l = new OpenSim::WeldJoint("mtp_l", *calcn_l, Vec3(0.16340967877419901311, -0.00182784875586351997, -0.00098703832816630292), Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), *toes_l, Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000));

	OpenSim::WeldJoint* mtp_r;
	mtp_r = new OpenSim::WeldJoint("mtp_r", *calcn_r, Vec3(0.16340967877419901311, -0.00182784875586351997, 0.00098703832816630292), Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), *toes_r, Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000));

	OpenSim::PinJoint* lumbar;
	lumbar = new OpenSim::PinJoint("lumbar", *pelvis, Vec3(-0.09724999260582140037, 0.07870778944761119833, 0.00000000000000000000), Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), *torso, Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000), Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000));

	model->addJoint(groundPelvis);
	model->addJoint(hip_l);
	model->addJoint(hip_r);
	model->addJoint(knee_l);
	model->addJoint(knee_r);
	model->addJoint(ankle_l);
	model->addJoint(ankle_r);
	model->addJoint(subtalar_l);
	model->addJoint(subtalar_r);
	model->addJoint(mtp_l);
	model->addJoint(mtp_r);
	model->addJoint(lumbar);

	OpenSim::SmoothSphereHalfSpaceForce* contactHeel_r;
	contactHeel_r = new SmoothSphereHalfSpaceForce("contactHeel_r", *calcn_r, model->getGround());
	Vec3 contactHeel_r_location(0.03130752758193179608, 0.01043584252731059869, 0.00000000000000000000);
	contactHeel_r->set_contact_sphere_location(contactHeel_r_location);
	double contactHeel_r_radius = (0.03500000000000000333);
	contactHeel_r->set_contact_sphere_radius(contactHeel_r_radius );
	contactHeel_r->set_contact_half_space_location(Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000));
	contactHeel_r->set_contact_half_space_orientation(Vec3(0.00000000000000000000, 0.00000000000000000000, -1.57079632679489655800));
	contactHeel_r->set_stiffness(3067776.00000000000000000000);
	contactHeel_r->set_dissipation(2.00000000000000000000);
	contactHeel_r->set_static_friction(0.80000000000000004441);
	contactHeel_r->set_dynamic_friction(0.80000000000000004441);
	contactHeel_r->set_viscous_friction(0.50000000000000000000);
	contactHeel_r->set_transition_velocity(0.20000000000000001110);
	contactHeel_r->set_constant_contact_force(0.00001000000000000000);
	contactHeel_r->set_hertz_smoothing(300.00000000000000000000);
	contactHeel_r->set_hunt_crossley_smoothing(50.00000000000000000000);
	contactHeel_r->connectSocket_sphere_frame(*calcn_r);
	contactHeel_r->connectSocket_half_space_frame(model->getGround());
	model->addComponent(contactHeel_r);

	OpenSim::SmoothSphereHalfSpaceForce* contactHeel_l;
	contactHeel_l = new SmoothSphereHalfSpaceForce("contactHeel_l", *calcn_l, model->getGround());
	Vec3 contactHeel_l_location(0.03130752758193179608, 0.01043584252731059869, 0.00000000000000000000);
	contactHeel_l->set_contact_sphere_location(contactHeel_l_location);
	double contactHeel_l_radius = (0.03500000000000000333);
	contactHeel_l->set_contact_sphere_radius(contactHeel_l_radius );
	contactHeel_l->set_contact_half_space_location(Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000));
	contactHeel_l->set_contact_half_space_orientation(Vec3(0.00000000000000000000, 0.00000000000000000000, -1.57079632679489655800));
	contactHeel_l->set_stiffness(3067776.00000000000000000000);
	contactHeel_l->set_dissipation(2.00000000000000000000);
	contactHeel_l->set_static_friction(0.80000000000000004441);
	contactHeel_l->set_dynamic_friction(0.80000000000000004441);
	contactHeel_l->set_viscous_friction(0.50000000000000000000);
	contactHeel_l->set_transition_velocity(0.20000000000000001110);
	contactHeel_l->set_constant_contact_force(0.00001000000000000000);
	contactHeel_l->set_hertz_smoothing(300.00000000000000000000);
	contactHeel_l->set_hunt_crossley_smoothing(50.00000000000000000000);
	contactHeel_l->connectSocket_sphere_frame(*calcn_l);
	contactHeel_l->connectSocket_half_space_frame(model->getGround());
	model->addComponent(contactHeel_l);

	OpenSim::SmoothSphereHalfSpaceForce* contactFront_r;
	contactFront_r = new SmoothSphereHalfSpaceForce("contactFront_r", *calcn_r, model->getGround());
	Vec3 contactFront_r_location(0.17740932296428019166, -0.01565376379096589804, 0.00521792126365529935);
	contactFront_r->set_contact_sphere_location(contactFront_r_location);
	double contactFront_r_radius = (0.01499999999999999944);
	contactFront_r->set_contact_sphere_radius(contactFront_r_radius );
	contactFront_r->set_contact_half_space_location(Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000));
	contactFront_r->set_contact_half_space_orientation(Vec3(0.00000000000000000000, 0.00000000000000000000, -1.57079632679489655800));
	contactFront_r->set_stiffness(3067776.00000000000000000000);
	contactFront_r->set_dissipation(2.00000000000000000000);
	contactFront_r->set_static_friction(0.80000000000000004441);
	contactFront_r->set_dynamic_friction(0.80000000000000004441);
	contactFront_r->set_viscous_friction(0.50000000000000000000);
	contactFront_r->set_transition_velocity(0.20000000000000001110);
	contactFront_r->set_constant_contact_force(0.00001000000000000000);
	contactFront_r->set_hertz_smoothing(300.00000000000000000000);
	contactFront_r->set_hunt_crossley_smoothing(50.00000000000000000000);
	contactFront_r->connectSocket_sphere_frame(*calcn_r);
	contactFront_r->connectSocket_half_space_frame(model->getGround());
	model->addComponent(contactFront_r);

	OpenSim::SmoothSphereHalfSpaceForce* contactFront_l;
	contactFront_l = new SmoothSphereHalfSpaceForce("contactFront_l", *calcn_l, model->getGround());
	Vec3 contactFront_l_location(0.17740932296428019166, -0.01565376379096589804, -0.00521792126365529935);
	contactFront_l->set_contact_sphere_location(contactFront_l_location);
	double contactFront_l_radius = (0.01499999999999999944);
	contactFront_l->set_contact_sphere_radius(contactFront_l_radius );
	contactFront_l->set_contact_half_space_location(Vec3(0.00000000000000000000, 0.00000000000000000000, 0.00000000000000000000));
	contactFront_l->set_contact_half_space_orientation(Vec3(0.00000000000000000000, 0.00000000000000000000, -1.57079632679489655800));
	contactFront_l->set_stiffness(3067776.00000000000000000000);
	contactFront_l->set_dissipation(2.00000000000000000000);
	contactFront_l->set_static_friction(0.80000000000000004441);
	contactFront_l->set_dynamic_friction(0.80000000000000004441);
	contactFront_l->set_viscous_friction(0.50000000000000000000);
	contactFront_l->set_transition_velocity(0.20000000000000001110);
	contactFront_l->set_constant_contact_force(0.00001000000000000000);
	contactFront_l->set_hertz_smoothing(300.00000000000000000000);
	contactFront_l->set_hunt_crossley_smoothing(50.00000000000000000000);
	contactFront_l->connectSocket_sphere_frame(*calcn_l);
	contactFront_l->connectSocket_half_space_frame(model->getGround());
	model->addComponent(contactFront_l);

	// Initialize system.
	SimTK::State* state;
	state = new State(model->initSystem());

	// Read inputs.
	std::vector<T> x(arg[0], arg[0] + NX);
	std::vector<T> u(arg[1], arg[1] + NU);

	// States and controls.
	T ua[nCoordinates];
	Vector QsUs(NX);
	/// States
	for (int i = 0; i < NX; ++i) QsUs[i] = x[i];
	/// Controls
	/// OpenSim and Simbody have different state orders.
	auto indicesOSInSimbody = getIndicesOSInSimbody(*model);
	for (int i = 0; i < nCoordinates; ++i) ua[i] = u[indicesOSInSimbody[i]];

	// Set state variables and realize.
	model->setStateVariableValues(*state, QsUs);
	model->realizeVelocity(*state);

	// Compute residual forces.
	/// Set appliedMobilityForces (# mobilities).
	Vector appliedMobilityForces(nCoordinates);
	appliedMobilityForces.setToZero();
	/// Set appliedBodyForces (# bodies + ground).
	Vector_<SpatialVec> appliedBodyForces;
	int nbodies = model->getBodySet().getSize() + 1;
	appliedBodyForces.resize(nbodies);
	appliedBodyForces.setToZero();
	/// Set gravity.
	Vec3 gravity(0);
	gravity[0] = 0.00000000000000000000;
	gravity[1] = -9.80664999999999942304;
	gravity[2] = 0.00000000000000000000;
	/// Add weights to appliedBodyForces.
	for (int i = 0; i < model->getBodySet().getSize(); ++i) {
		model->getMatterSubsystem().addInStationForce(*state,
		model->getBodySet().get(i).getMobilizedBodyIndex(),
		model->getBodySet().get(i).getMassCenter(),
		model->getBodySet().get(i).getMass()*gravity, appliedBodyForces);
	}
	/// Add contact forces to appliedBodyForces.
	Array<osim_double_adouble> Force_0 = contactHeel_r->getRecordValues(*state);
	SpatialVec GRF_0;
	GRF_0[0] = Vec3(Force_0[3], Force_0[4], Force_0[5]);
	GRF_0[1] = Vec3(Force_0[0], Force_0[1], Force_0[2]);
	int c_idx_0 = model->getBodySet().get("calcn_r").getMobilizedBodyIndex();
	appliedBodyForces[c_idx_0] += GRF_0;

	Array<osim_double_adouble> Force_1 = contactHeel_l->getRecordValues(*state);
	SpatialVec GRF_1;
	GRF_1[0] = Vec3(Force_1[3], Force_1[4], Force_1[5]);
	GRF_1[1] = Vec3(Force_1[0], Force_1[1], Force_1[2]);
	int c_idx_1 = model->getBodySet().get("calcn_l").getMobilizedBodyIndex();
	appliedBodyForces[c_idx_1] += GRF_1;

	Array<osim_double_adouble> Force_2 = contactFront_r->getRecordValues(*state);
	SpatialVec GRF_2;
	GRF_2[0] = Vec3(Force_2[3], Force_2[4], Force_2[5]);
	GRF_2[1] = Vec3(Force_2[0], Force_2[1], Force_2[2]);
	int c_idx_2 = model->getBodySet().get("calcn_r").getMobilizedBodyIndex();
	appliedBodyForces[c_idx_2] += GRF_2;

	Array<osim_double_adouble> Force_3 = contactFront_l->getRecordValues(*state);
	SpatialVec GRF_3;
	GRF_3[0] = Vec3(Force_3[3], Force_3[4], Force_3[5]);
	GRF_3[1] = Vec3(Force_3[0], Force_3[1], Force_3[2]);
	int c_idx_3 = model->getBodySet().get("calcn_l").getMobilizedBodyIndex();
	appliedBodyForces[c_idx_3] += GRF_3;

	/// knownUdot.
	Vector knownUdot(nCoordinates);
	knownUdot.setToZero();
	for (int i = 0; i < nCoordinates; ++i) knownUdot[i] = ua[i];

	/// Calculate residual forces.
	Vector residualMobilityForces(nCoordinates);
	residualMobilityForces.setToZero();
	model->getMatterSubsystem().calcResidualForceIgnoringConstraints(*state,
			appliedMobilityForces, appliedBodyForces, knownUdot, residualMobilityForces);

	/// Ground reaction forces.
	SpatialVec GRF_r;
	SpatialVec GRF_l;
	GRF_r.setToZero();
	GRF_l.setToZero();

	GRF_r += GRF_0;
	GRF_l += GRF_1;
	GRF_r += GRF_2;
	GRF_l += GRF_3;

	/// Ground reaction moments.
	SpatialVec GRM_r;
	SpatialVec GRM_l;
	GRM_r.setToZero();
	GRM_l.setToZero();
	Vec3 normal(0, 1, 0);

	SimTK::Transform TR_GB_calcn_r = calcn_r->getMobilizedBody().getBodyTransform(*state);
	Vec3 contactHeel_r_location_G = calcn_r->findStationLocationInGround(*state, contactHeel_r_location);
	Vec3 contactHeel_r_locationCP_G = contactHeel_r_location_G - contactHeel_r_radius * normal;
	Vec3 locationCP_G_adj_0 = contactHeel_r_locationCP_G - 0.5*contactHeel_r_locationCP_G[1] * normal;
	Vec3 contactHeel_r_locationCP_B = model->getGround().findStationLocationInAnotherFrame(*state, locationCP_G_adj_0, *calcn_r);
	Vec3 GRM_0 = (TR_GB_calcn_r*contactHeel_r_locationCP_B) % GRF_0[1];
	GRM_r += GRM_0;

	SimTK::Transform TR_GB_calcn_l = calcn_l->getMobilizedBody().getBodyTransform(*state);
	Vec3 contactHeel_l_location_G = calcn_l->findStationLocationInGround(*state, contactHeel_l_location);
	Vec3 contactHeel_l_locationCP_G = contactHeel_l_location_G - contactHeel_l_radius * normal;
	Vec3 locationCP_G_adj_1 = contactHeel_l_locationCP_G - 0.5*contactHeel_l_locationCP_G[1] * normal;
	Vec3 contactHeel_l_locationCP_B = model->getGround().findStationLocationInAnotherFrame(*state, locationCP_G_adj_1, *calcn_l);
	Vec3 GRM_1 = (TR_GB_calcn_l*contactHeel_l_locationCP_B) % GRF_1[1];
	GRM_l += GRM_1;

	Vec3 contactFront_r_location_G = calcn_r->findStationLocationInGround(*state, contactFront_r_location);
	Vec3 contactFront_r_locationCP_G = contactFront_r_location_G - contactFront_r_radius * normal;
	Vec3 locationCP_G_adj_2 = contactFront_r_locationCP_G - 0.5*contactFront_r_locationCP_G[1] * normal;
	Vec3 contactFront_r_locationCP_B = model->getGround().findStationLocationInAnotherFrame(*state, locationCP_G_adj_2, *calcn_r);
	Vec3 GRM_2 = (TR_GB_calcn_r*contactFront_r_locationCP_B) % GRF_2[1];
	GRM_r += GRM_2;

	Vec3 contactFront_l_location_G = calcn_l->findStationLocationInGround(*state, contactFront_l_location);
	Vec3 contactFront_l_locationCP_G = contactFront_l_location_G - contactFront_l_radius * normal;
	Vec3 locationCP_G_adj_3 = contactFront_l_locationCP_G - 0.5*contactFront_l_locationCP_G[1] * normal;
	Vec3 contactFront_l_locationCP_B = model->getGround().findStationLocationInAnotherFrame(*state, locationCP_G_adj_3, *calcn_l);
	Vec3 GRM_3 = (TR_GB_calcn_l*contactFront_l_locationCP_B) % GRF_3[1];
	GRM_l += GRM_3;

	/// Contact spheres deformation power.
	Vec3 contactHeel_r_velocity_G = calcn_r->findStationVelocityInGround(*state, contactHeel_r_location);
	osim_double_adouble P_HC_y_0 = contactHeel_r_velocity_G[1]*GRF_0[1][1];
	Vec3 contactHeel_l_velocity_G = calcn_l->findStationVelocityInGround(*state, contactHeel_l_location);
	osim_double_adouble P_HC_y_1 = contactHeel_l_velocity_G[1]*GRF_1[1][1];
	Vec3 contactFront_r_velocity_G = calcn_r->findStationVelocityInGround(*state, contactFront_r_location);
	osim_double_adouble P_HC_y_2 = contactFront_r_velocity_G[1]*GRF_2[1][1];
	Vec3 contactFront_l_velocity_G = calcn_l->findStationVelocityInGround(*state, contactFront_l_location);
	osim_double_adouble P_HC_y_3 = contactFront_l_velocity_G[1]*GRF_3[1][1];
	/// Outputs.
	/// Residual forces (OpenSim and Simbody have different state orders).
	auto indicesSimbodyInOS = getIndicesSimbodyInOS(*model);
	for (int i = 0; i < nCoordinates; ++i) res[0][i] =
			value<T>(residualMobilityForces[indicesSimbodyInOS[i]]);
	/// Ground reaction forces.
	for (int i = 0; i < 3; ++i) res[0][i + nCoordinates + 0] = value<T>(GRF_r[1][i]);
	for (int i = 0; i < 3; ++i) res[0][i + nCoordinates + 3] = value<T>(GRF_l[1][i]);
	/// Separate Ground reaction forces.
	for (int i = 0; i < 3; ++i) res[0][i + nCoordinates + 6] = value<T>(GRF_0[1][i]);
	for (int i = 0; i < 3; ++i) res[0][i + nCoordinates + 9] = value<T>(GRF_1[1][i]);
	for (int i = 0; i < 3; ++i) res[0][i + nCoordinates + 12] = value<T>(GRF_2[1][i]);
	for (int i = 0; i < 3; ++i) res[0][i + nCoordinates + 15] = value<T>(GRF_3[1][i]);
	/// Ground reaction moments.
	for (int i = 0; i < 3; ++i) res[0][i + nCoordinates + 18] = value<T>(GRM_r[1][i]);
	for (int i = 0; i < 3; ++i) res[0][i + nCoordinates + 21] = value<T>(GRM_l[1][i]);
	/// Contact spheres deformation power.
	res[0][nCoordinates + 24] = value<T>(P_HC_y_0);
	res[0][nCoordinates + 25] = value<T>(P_HC_y_1);
	res[0][nCoordinates + 26] = value<T>(P_HC_y_2);
	res[0][nCoordinates + 27] = value<T>(P_HC_y_3);

	return 0;
}

int main() {
	Recorder x[NX];
	Recorder u[NU];
	Recorder tau[NR];
	for (int i = 0; i < NX; ++i) x[i] <<= 0;
	for (int i = 0; i < NU; ++i) u[i] <<= 0;
	const Recorder* Recorder_arg[n_in] = { x,u };
	Recorder* Recorder_res[n_out] = { tau };
	F_generic<Recorder>(Recorder_arg, Recorder_res);
	double res[NR];
	for (int i = 0; i < NR; ++i) Recorder_res[0][i] >>= res[i];
	Recorder::stop_recording();
	return 0;
}
