#!/usr/bin/env ruby

require 'pp'
require './initial_state.rb'

# Constants
ROOF_WALL = 0.5
RIGHT_WALL = 0.5
FLOOR_WALL = 0
LEFT_WALL = 0
PARTICLES_RADIUS = 0.005
PARTICLES_MASS = 1
BIG_PARTICLE_RADIUS = 0.05
BIG_PARTICLE_MASS = 100

# Particles amount
N = ARGV[0].to_i
raise ArgumentError, "The amount of particles must be bigger than zero" if N <= 0

particles = generate_particles
pp particles