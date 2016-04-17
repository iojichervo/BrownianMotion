#!/usr/bin/env ruby

require 'set'
require './particle.rb'
require './point.rb'

# Generate the random particles and the big one in the box
def generate_particles
  particles = Set.new

  big_particle = Particle.new(BIG_PARTICLE_RADIUS, BIG_PARTICLE_MASS, random_position(BIG_PARTICLE_RADIUS, particles), 0, 0)
  particles.add(big_particle)

  N.times do
    vx = rand(-0.1..0.1)
    vy = rand(-0.1..0.1)
    new_particle = Particle.new(PARTICLES_RADIUS, PARTICLES_MASS, random_position(PARTICLES_RADIUS, particles), vx, vy)
    particles.add(new_particle)
  end

  return particles
end

# Return a new position for a new particle
def random_position(new_particle_radius, particles)
  x = nil
  y = nil

  loop do 
    x = rand(LEFT_WALL..RIGHT_WALL)
    y = rand(FLOOR_WALL..ROOF_WALL)
    break if verify_new_position(x, y, new_particle_radius, particles)
  end 

  return Point.new(x, y)
end

def verify_new_position(x, y, r, particles)
  # Check if particle is in the box
  return false if x - r < LEFT_WALL || x + r > RIGHT_WALL || y - r < FLOOR_WALL || y + r > ROOF_WALL

  # Check if the potential new position overlaps with the other particles
  particles.each do |particle|
    if (x - particle.x)**2 + (y - particle.y)**2 <= (r + particle.radius)**2 then
      return false
    end
  end

  return true
end
