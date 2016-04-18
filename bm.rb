#!/usr/bin/env ruby

require 'pp'
require './initial_state.rb'
require './cim.rb'
require './collision.rb'

def next_collision(particles)
  nc = nil
  particles.each do |particle|
    # Next collision of particle in x
    if particle.vx > 0 then
      tncx = (RIGHT_WALL - particle.radius - particle.x) / particle.vx
    elsif particle.vx < 0
      tncx = (LEFT_WALL + particle.radius - particle.x) / particle.vx
    else
      tncx = nil
    end
    ncx = HorizontalCollision.new(particle, tncx)

    # Next collision of particle in y
    if particle.vy > 0 then
      tncy = (ROOF_WALL - particle.radius - particle.y) / particle.vy
    elsif particle.vy < 0
      tncy = (FLOOR_WALL + particle.radius - particle.y) / particle.vy
    else
      tncy = nil
    end
    ncy = VerticalCollision.new(particle, tncy)

    # Next collision of particle with other particle
    ncp = nil
    particle.neighbors.each do |neighbor|
      σ = particle.radius + neighbor.radius
      △r△r = (neighbor.x - particle.x)**2 + (neighbor.y - particle.y)**2
      △v△v = (neighbor.vx - particle.vx)**2 + (neighbor.vy - particle.vy)**2
      △v△r = (neighbor.vx - particle.vx)*(neighbor.x - particle.x) + (neighbor.vy - particle.vy)*(neighbor.y - particle.y)
      d = △v△r**2 - △v△v * (△r△r - σ**2)

      if △v△r < 0 && d >= 0 then
        tncp = - (△v△r + Math.sqrt(d)) / △v△v
        ncp = Collision.new(particle, neighbor, tncp) if ncp == nil || tncp < ncp.time
      end
    end

    # Next collision
    nc = min_time_collisions(nc, ncx, ncy, ncp)
  end
  return nc
end

def min_time_collisions(*collisions)
  min = nil
  collisions.each do |c|
    min = c if min == nil || min.time == nil
    min = c if c != nil && min != nil && c.time != nil && min.time != nil && c.time < min.time
  end
  return min
end

def move(particles, time)
  particles.each do |p|
    p.move(time)
  end
end

def print_next_state(state, mode, second)
  file = File.open("particles.txt", mode)
  file.write("#{N + 1}\n")
  file.write("#{second}\n")
  state.particles.each do |particle|
    file.write("#{particle.x} #{particle.y} #{particle.vx} #{particle.vy} #{particle.radius}\n")
  end
  #file.write("#{LEFT_WALL} #{FLOOR_WALL} 0 0 0\n")
  #file.write("#{LEFT_WALL} #{ROOF_WALL} 0 0 0\n")
  #file.write("#{RIGHT_WALL} #{FLOOR_WALL} 0 0 0\n")
  #file.write("#{RIGHT_WALL} #{ROOF_WALL} 0 0 0\n")
  file.close
end

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
#N = ARGV[0].to_i
N = 10
T = 15
raise ArgumentError, "The amount of particles must be bigger than zero" if N <= 0

i = 0
particles = generate_particles
state = state(RIGHT_WALL, 4, 0.001, N, particles)
print_next_state(state, 'w', i)

actual_time = 0
△t = 0.1
while actual_time <= T do
  nc = next_collision(particles)

  if nc.time <= △t then
    nc.collide

    state.grid = {}
    align_grid(state)
    cell_index_method(state, 0.001, false)
  else
    move(particles, △t)
    actual_time += △t

    i += 1
    print_next_state(state, 'a', i) 
  end

end