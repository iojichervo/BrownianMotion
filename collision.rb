#!/usr/bin/env ruby

class Collision
  attr_reader :particle, :other_particle, :time

  def initialize(particle, other_particle, time)
    @particle = particle
    @other_particle = other_particle
    @time = time
    @is_valid = true
  end

  def collide
    σ = particle.radius + other_particle.radius
    △v△r = (other_particle.vx - particle.vx)*(other_particle.x - particle.x) + (other_particle.vy - particle.vy)*(other_particle.y - particle.y)

    j = (2 * particle.mass * other_particle.mass * △v△r) / (σ * (particle.mass + other_particle.mass))
    △x = other_particle.x - particle.x
    jx = j * △x / σ
    △y = other_particle.y - particle.y
    jy = j * △y / σ

    particle.vx += jx / particle.mass
    particle.vy += jy / particle.mass
    other_particle.vx -= jx / other_particle.mass
    other_particle.vy -= jy / other_particle.mass
  end

  def particles
    [particle, other_particle]
  end

  def is_valid
    is_valid
  end

  def invalidate
    is_invalid = false
  end
end

class HorizontalCollision < Collision
  def initialize(particle, time)
    super(particle, nil, time)
  end

  def collide
    @particle.vx *= -1
  end

  def particles
    [particle]
  end
end

class VerticalCollision < Collision
  def initialize(particle, time)
    super(particle, nil, time)
  end

  def collide
    @particle.vy *= -1
  end

  def particles
    [particle]
  end
end