#__precompile__(false)

module ISOKANN

#using Startup           # precompiles most used packages

#include("forced/IsoForce.jl")

import Random

using LinearAlgebra: norm, dot, cross, diag
using StatsBase: mean, sample, mean_and_std
using Molly: Molly, System
using StaticArrays: SVector
using StatsBase: sample
using CUDA: CuArray, CuMatrix, cu, CUDA
using NNlib: batched_adjoint, batched_mul
using Unitful: @u_str, unit
import ProgressMeter
using SpecialFunctions: erf
using Plots: plot, plot!, scatter, scatter!

using MLUtils: numobs, getobs, shuffleobs, unsqueeze

import ChainRulesCore
import Flux
import StatsBase, Zygote, Optimisers, Flux, JLD2
import LsqFit
import JLD2
import Flux
import NNlib
import MLUtils
import Zygote
import OrdinaryDiffEq

export pairnet#, pairnetn
export PDB_ACEMD, PDB_1UAO, PDB_diala_water
export MollyLangevin, propagate, solve#, MollySDE
export IsoRun, run!, AdamRegularized#, Adam
export plot_learning, scatter_ramachandran
export reactionpath

import Flux: cpu, gpu
export cpu, gpu


export iso2
export Doublewell, Triplewell, MuellerBrown



include("subsample.jl")  # adaptive sampling
include("pairdists.jl")       # pair distances
include("simulators/simulation.jl")      # Langevin dynamic simulator (MollySystem+Integrator)
include("models.jl")          # the neural network models/architectures
include("simulators/molly.jl")           # interface to work with Molly Systems
include("molutils.jl")        # molecular utilities: dihedrals, rotation
include("data.jl")            # tools for handling the data (sampling, slicing, ...)
include("iso1.jl")        # ISOKANN for Molly systems
include("plots.jl")           # visualizations
#include("loggers.jl")     # performance metric loggers
#include("benchmarks.jl")      # benchmark runs, deprecated by scripts/*
include("reactionpath.jl")

include("simulators/langevin.jl")  # for the simulators

include("isosimple.jl")
include("iso2.jl")
include("simulators/potentials.jl")

include("simulators/openmm.jl")

import .OpenMM.OpenMMSimulation
export OpenMMSimulation

include("cuda.jl")            # fixes for cuda

#include("dataloader.jl")

#include("precompile.jl") # precompile for faster ttx

include("IsoMu/IsoMu.jl")

end
