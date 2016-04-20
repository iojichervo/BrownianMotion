#!/usr/bin/env ruby

require 'pp'
require './initial_state.rb'
require './cim.rb'
require './collision.rb'

# Returns the next collision between the particles
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
    particles.each do |neighbor|
      if neighbor.id != particle.id then
        σ = particle.radius + neighbor.radius
        △r△r = (neighbor.x - particle.x)**2 + (neighbor.y - particle.y)**2
        △v△v = (neighbor.vx - particle.vx)**2 + (neighbor.vy - particle.vy)**2
        △v△r = (neighbor.vx - particle.vx)*(neighbor.x - particle.x) + (neighbor.vy - particle.vy)*(neighbor.y - particle.y)
        d = △v△r**2 - △v△v * (△r△r - σ**2)

        if △v△r < 0 && d >= 0 then
          tncp = - (△v△r + Math.sqrt(d)) / △v△v
          ncp = ParticlesCollision.new(particle, neighbor, tncp) if ncp == nil || tncp < ncp.time
        end
      end
    end

    # Next collision
    nc = min_time_collisions(nc, ncx, ncy, ncp)
  end
  return nc
end

# Returns the collision with the minimum time
def min_time_collisions(*collisions)
  min = nil
  collisions.each do |c|
    min = c if min == nil || min.time == nil
    min = c if c != nil && min != nil && c.time != nil && min.time != nil && c.time < min.time
  end
  return min
end

# Moves all the particles a certain time
def move(particles, time)
  particles.each do |p|
    p.move(time)
  end
end

# Prints each particle at a given time
def print_next_state(particles, mode, second)
  file = File.open("particles.txt", mode)
  file.write("#{N + 1 + 4}\n") # 1 for the big particle, 4 for the invisible ones at the corners
  file.write("#{second}\n")
  particles.each do |particle|
    file.write("#{particle.x} #{particle.y} #{particle.vx} #{particle.vy} #{particle.radius}\n")
  end
  file.write("#{LEFT_WALL} #{FLOOR_WALL} 0 0 0\n")
  file.write("#{LEFT_WALL} #{ROOF_WALL} 0 0 0\n")
  file.write("#{RIGHT_WALL} #{FLOOR_WALL} 0 0 0\n")
  file.write("#{RIGHT_WALL} #{ROOF_WALL} 0 0 0\n")
  file.close
end

# Returns the next frame of a certain time
def next_frame(time)
  △t = 0.1
  return (time.round(1) - time > 0 ? time.round(1) : time.round(1) + △t).round(1)
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
FRAMES = 500

# Particles amount
#N = ARGV[0].to_i
N = 100
raise ArgumentError, "The amount of particles must be bigger than zero" if N <= 0

particles = generate_particles
print_next_state(particles, 'w', 0)

actual_time = 0
i = 0

# Measurements
times_collisions = []
velocities = []
while i < FRAMES do
  nc = next_collision(particles)

  if next_frame(actual_time) == next_frame(nc.time + actual_time) then
    move(particles, nc.time)
    nc.collide
    actual_time += nc.time

    # Measurements
    times_collisions.push(nc.time)
  else
    next_frame = next_frame(actual_time)
    move(particles, next_frame - actual_time) # Must move △t or less
    actual_time = next_frame

    print_next_state(particles, 'a', actual_time)
    i += 1

    # Measurements
    if actual_time > (2.0/3.0) * FRAMES * 0.1 then
      particles.each do |p|
        velocities.push(p.speed)
      end
    end
  end

end

# Measurements
sum_times_collisions = times_collisions.inject(:+)
amount_collisions = times_collisions.size

puts "Frequency of collisions: #{amount_collisions / actual_time}"
puts "Average time of collsions: #{(sum_times_collisions / amount_collisions).round(3)}"

step = 0.005
distribution = Hash.new(0)
times_collisions.each do |time|
  destination = ((time.round(3)*100) - ((time.round(3)*100) % (step*100))) / 100
  distribution[destination] += 1
end

puts "Distribution of collisions: #{distribution}"

step = 0.01
distribution = Hash.new(0)
velocities.each do |v|
  destination = ((v.round(3)*100) - ((v.round(3)*100) % (step*100))) / 100
  distribution[destination] += 1
end

puts "Distribution of velocities: #{distribution}"