[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 50
  ny = 25
  xmin = 0
  xmax = 20
  ymin = 0
  ymax = 10
[]

[Variables]
  [./c]
    initial_condition = 0.1
    #[./InitialCondition]
    #  type = FunctionIC
    #  function = 'x0:=5.0;thk:=0.5;m:=2;r:=abs(x-x0);v:=exp(-(r/thk)^m);0.1+0.1*v'
    #[../]
  [../]
  [./mu]
  [../]
[]

[AuxVariables]
  [./gb]
    family = MONOMIAL
    order  = CONSTANT
  [../]
  [./mobility_xx]
    family = MONOMIAL
    order  = CONSTANT
  [../]
  [./mobility_yy]
    family = MONOMIAL
    order  = CONSTANT
  [../]
  [./diffusivity_xx]
    family = MONOMIAL
    order  = CONSTANT
  [../]
  [./diffusivity_yy]
    family = MONOMIAL
    order  = CONSTANT
  [../]
  [./aniso_tensor_xx]
    family = MONOMIAL
    order  = CONSTANT
  [../]
  [./aniso_tensor_yy]
    family = MONOMIAL
    order  = CONSTANT
  [../]
[]

[Kernels]
  [./conc]
    type = CHSplitConcentration
    variable = c
    mobility = mobility_prop
    chemical_potential_var = mu
  [../]
  [./chempot]
    type = CHSplitChemicalPotential
    variable = mu
    chemical_potential_prop = mu_prop
    c = c
  [../]
  [./time]
    type = TimeDerivative
    variable = c
  [../]
[]

[AuxKernels]
  [./gb]
    type = FunctionAux
    variable = gb
    function = 'y0:=5.0;thk:=0.5;m:=2;r:=abs(y-y0);v:=exp(-(r/thk)^m);v'
  [../]
  [./mobility_xx]
    type = MaterialRealTensorValueAux
    variable = mobility_xx
    property = mobility_prop
    row = 0
    column = 0
  [../]
  [./mobility_yy]
    type = MaterialRealTensorValueAux
    variable = mobility_yy
    property = mobility_prop
    row = 1
    column = 1
  [../]
  [./diffusivity_xx]
    type = MaterialRealTensorValueAux
    variable = diffusivity_xx
    property = diffusivity
    row = 0
    column = 0
  [../]
  [./diffusivity_yy]
    type = MaterialRealTensorValueAux
    variable = diffusivity_yy
    property = diffusivity
    row = 1
    column = 1
  [../]
  [./aniso_tensor_xx]
    type = MaterialRealTensorValueAux
    variable = aniso_tensor_xx
    property = aniso_tensor
    row = 0
    column = 0
  [../]
  [./aniso_tensor_yy]
    type = MaterialRealTensorValueAux
    variable = aniso_tensor_yy
    property = aniso_tensor
    row = 1
    column = 1
  [../]
[]

[Materials]
  [./chemical_potential]
    type = DerivativeParsedMaterial
    block = 0
    f_name = mu_prop
    args = c
    function = 'c'
    derivative_order = 1
  [../]
  [./var_dependence]
    type = DerivativeParsedMaterial
    block = 0
    function = 'c*(1.0-c)'
    args = c
    f_name = var_dep
    derivative_order = 1
  [../]
  [./mobility]
    type = CompositeMobilityTensor
    block = 0
    M_name = mobility_prop
    tensors = diffusivity
    weights = var_dep
    args = c
  [../]
  [./phase_normal]
    type = PhaseNormalTensor
    phase = gb
    normal_tensor_name = gb_normal
  [../]
  [./aniso_tensor]
    type = GBDependentAnisotropicTensor
    gb = gb
    bulk_parameter = 0.01
    gb_parameter = 10
    gb_normal_tensor_name = gb_normal
    gb_tensor_prop_name = aniso_tensor
  [../]
  [./diffusivity]
    type = GBDependentDiffusivity
    gb = gb
    bulk_parameter = 0.01
    gb_parameter = 10
    gb_normal_tensor_name = gb_normal
    gb_tensor_prop_name = diffusivity
  [../]
[]

[BCs]
  [./Periodic]
    [./all]
      auto_direction = 'y'
    [../]
  [../]
  [./left]
    type = DirichletBC
    variable = c
    boundary = left
    value = 0.2
  [../]
  #[./right]
  #  type = DirichletBC
  #  variable = c
  #  boundary = right
  #  value = 0.1
  #[../]
  [./out_flux]
    type = CahnHilliardAnisoFluxBC
    variable = mu
    boundary = right
    flux = '0 0.1 0'
    mob_name = mobility_xx
    args = 'c'
  [../]
[]

[Preconditioning]
  [./smp]
     type = SMP
     full = true
  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
  type = Transient
  num_steps = 100
  dt = 1
  solve_type = PJFNK

  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm      31                  preonly       lu           1'

  l_tol = 1e-3
  l_max_its = 20
  nl_max_its = 5

  #[./TimeStepper]
  #  type = IterationAdaptiveDT
  #  dt = 25 # Initial time step.  In this simulation it changes.
  #  optimal_iterations = 6 # Time step will adapt to maintain this number of nonlinear iterations
  #[../]
  #[./Adaptivity]
  #  # Block that turns on mesh adaptivity. Note that mesh will never coarsen beyond initial mesh (before uniform refinement)
  #  initial_adaptivity = 4 # Number of times mesh is adapted to initial condition
  #  refine_fraction = 0.1 # Fraction of high error that will be refined
  #  coarsen_fraction = 0.1 # Fraction of low error that will coarsened
  #  max_h_level = 5 # Max number of refinements used, starting from initial mesh (before uniform refinement)
  #[../]
[]

[Outputs]
  exodus = true
[]
