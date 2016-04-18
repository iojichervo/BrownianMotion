#!/usr/bin/env ruby

class Collision
  attr_reader :particle, :other_particle, :time

  def initialize(particle, other_particle, time)
    @particle = particle
    @other_particle = other_particle
    @time = time
  end
end

class HorizontalCollision < Collision
  def initialize(particle, time)
    super(particle, nil, time)
  end
end

class VerticalCollision < Collision
  def initialize(particle, time)
    super(particle, nil, time)
  end
end